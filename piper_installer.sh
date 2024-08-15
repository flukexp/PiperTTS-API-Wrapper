#!/bin/bash

# Function to determine if running under WSL
is_wsl() {
    if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null || [ -n "$WSLENV" ]; then
        return 0  # True, running under WSL
    else
        return 1  # False, not running under WSL
    fi
}

# Function to determine the OS and architecture
get_os_architecture() {
    local os
    local arch

    os=$(uname)
    arch=$(uname -m)

    case "$os" in
        Darwin)
            case "$arch" in
                arm64) echo "macos_aarch64" ;;
                x86_64) echo "macos_x64" ;;
                *) echo "Unsupported macOS architecture: $arch" >&2; exit 1 ;;
            esac
            ;;
        Linux)
            if is_wsl; then
                echo "windows_amd64"
            else
                case "$arch" in
                    aarch64) echo "linux_aarch64" ;;
                    x86_64) echo "linux_x64" ;;
                    armv7l) echo "linux_armv7l" ;;
                    *) echo "Unsupported Linux architecture: $arch" >&2; exit 1 ;;
                esac
            fi
            ;;
        *)
            echo "Unsupported OS: $os" >&2
            exit 1
            ;;
    esac
}

# Function to check if Piper is already installed
check_if_installed() {
    if [ -x "./piper" ]; then
        echo "Piper is already installed."
        exit 0
    fi
}

check_if_installed

# Determine OS and architecture
architecture=$(get_os_architecture)

# Determine file extension based on the OS and architecture
case "$architecture" in
    "windows_amd64" )
        file_extension=".zip"
        ;;
    * )
        file_extension=".tar.gz"
        ;;
esac

# GitHub URL for the latest release
latest_release_url="https://github.com/rhasspy/piper/releases/latest"

# Get the redirect URL for the latest release
redirect_url=$(curl -sL -w '%{url_effective}' -o /dev/null "$latest_release_url")

# Extract the release tag from the redirect URL
release_tag=$(basename "$redirect_url")

# Construct the release file name and URL
release_file_name="piper_${architecture}${file_extension}"
release_file_url="https://github.com/rhasspy/piper/releases/download/$release_tag/$release_file_name"

# Download the release file
echo "Downloading $release_file_url..."
curl -L -o "$release_file_name" "$release_file_url"

# Create a temporary directory for extraction
temp_dir=$(mktemp -d)

# Extract the archive based on the OS and architecture
echo "Extracting $release_file_name..."
case "$architecture" in
    "windows_amd64" )
        if command -v unzip >/dev/null; then
            unzip "$release_file_name" -d "$temp_dir"
        else
            echo "unzip command not found. Please install it in WSL." >&2
            exit 1
        fi
        ;;
    * )
        if command -v tar >/dev/null; then
            tar -xzf "$release_file_name" -C "$temp_dir"
        else
            echo "tar command not found. Please install it." >&2
            exit 1
        fi
        ;;
esac

# Move all files from the temporary directory to the parent directory
echo "Moving files to the parent directory..."
mv "$temp_dir"/piper/* ./

# Clean up
rm -rf "$temp_dir"
rm "$release_file_name"

echo "Piper installation complete."
