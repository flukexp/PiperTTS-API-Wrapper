#!/bin/bash

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
            case "$arch" in
                aarch64) echo "linux_aarch64" ;;
                x86_64) echo "linux_x64" ;;
                armv7l) echo "linux_armv7l" ;;
                *)
                    if command -v wsl >/dev/null; then
                        echo "windows_amd64"
                    else
                        echo "Unsupported Linux architecture: $arch" >&2
                        exit 1
                    fi
                    ;;
            esac
            ;;
        *)
            echo "Unsupported OS: $os" >&2
            exit 1
            ;;
    esac
}

# Determine OS and architecture
architecture=$(get_os_architecture)

# Determine file extension based on the OS and architecture
case "$architecture" in
    windows_amd64 )
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

# Extract the archive based on the OS and architecture
echo "Extracting $release_file_name..."
case "$architecture" in
    windows_amd64 )
        if command -v unzip >/dev/null; then
            unzip "$release_file_name" -d ./extracted_files
        else
            echo "unzip command not found. Please install it in WSL." >&2
            exit 1
        fi
        ;;
    * )
        if command -v tar >/dev/null; then
            tar -xzf "$release_file_name" -C ./
        else
            echo "tar command not found. Please install it." >&2
            exit 1
        fi
        ;;
esac

# Clean up the downloaded archive
rm "$release_file_name"

echo "Piper installation complete."
