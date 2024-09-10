#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "${BLUE}==================== $1 ====================${NC}"
}

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error occurred: $1${NC}"
        exit 1
    fi
}

# Function to check if a command exists and install it if necessary
check_and_install() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${YELLOW}$1 not found. Installing...${NC}"
        install_package $2
    else
        echo -e "${GREEN}$1 is already installed.${NC}"
    fi
}

# Function to install a package based on the OS
install_package() {
    if [ "$(uname)" == "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            check_error "Failed to install Homebrew"
        fi
        brew install $1
    elif [ "$(uname)" == "Linux" ]; then
        sudo apt-get update
        sudo apt-get install -y $1
    else
        echo -e "${RED}Unsupported OS for package installation.${NC}"
        exit 1
    fi
    check_error "Failed to install $1"
    echo -e "${GREEN}$1 installed successfully.${NC}"
}

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
        Windows)
            echo "windows_amd64"
            ;;
        Linux)
            case "$arch" in
                aarch64) echo "linux_aarch64" ;;
                x86_64) echo "linux_x64" ;;
                armv7l) echo "linux_armv7l" ;;
                *) echo "Unsupported Linux architecture: $arch" >&2; exit 1 ;;
            esac
            ;;
        *)
            echo "Unsupported OS: $os" >&2
            exit 1
            ;;
    esac
}

# Function to check if Piper is already installed
check_if_installed() {
    if [ -x "./piper" ] || [ -x "./piper.exe" ]; then
        echo -e "${GREEN}Piper is already installed.${NC}"
        return 0
    else
        return 1
    fi
}

# Check for required dependencies
print_header "Checking Dependencies"
check_and_install curl curl
check_and_install node nodejs
check_and_install npm npm

# Check if Piper is already installed
print_header "Checking Piper Installation"
if check_if_installed; then
    print_header "Piper is already installed."

    # Downloading voice from voice_installer.sh
    print_header "Downloading voice from voice_installer.sh"
    chmod +x ./voices_installer.sh
    check_error "Failed to set execute permissions for voice_installer.sh"
    ./voices_installer.sh
    check_error "Failed to execute voice_installer.sh"

    # Install npm dependencies and start the application
    print_header "Installing npm Dependencies and Starting piper server"
    npm install .
    check_error "npm install failed"
    npm start
    check_error "npm start failed"
    
else
    # Determine OS and architecture
    print_header "Determining OS and Architecture"
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
    print_header "Fetching Latest Release"
    redirect_url=$(curl -sL -w '%{url_effective}' -o /dev/null "$latest_release_url")
    check_error "Failed to fetch latest release URL"

    # Extract the release tag from the redirect URL
    release_tag=$(basename "$redirect_url")

    # Construct the release file name and URL
    release_file_name="piper_${architecture}${file_extension}"
    release_file_url="https://github.com/rhasspy/piper/releases/download/$release_tag/$release_file_name"

    # Download the release file
    print_header "Downloading Piper"
    echo -e "${YELLOW}Downloading $release_file_url...${NC}"
    curl -L -o "$release_file_name" "$release_file_url"
    check_error "Failed to download $release_file_name"

    # Create a temporary directory for extraction
    temp_dir=$(mktemp -d)

    # Extract the archive based on the OS and architecture
    print_header "Extracting Piper"
    case "$architecture" in
        "windows_amd64" )
            if command -v unzip >/dev/null; then
                unzip "$release_file_name" -d "$temp_dir"
            else
                echo -e "${RED}unzip command not found. Please install it in WSL.${NC}" >&2
                exit 1
            fi
            ;;
        * )
            if command -v tar >/dev/null; then
                tar -xzf "$release_file_name" -C "$temp_dir"
            else
                echo -e "${RED}tar command not found. Please install it.${NC}" >&2
                exit 1
            fi
            ;;
    esac

    # Move all files from the temporary directory to the parent directory
    print_header "Moving Files"
    mv "$temp_dir"/piper/* ./

    # Clean up
    rm -rf "$temp_dir"
    rm "$release_file_name"

    # Downloading voice from voice_installer.sh
    print_header "Downloading voice from voice_installer.sh"
    chmod +x ./voices_installer.sh
    check_error "Failed to set execute permissions for voice_installer.sh"
    ./voices_installer.sh
    check_error "Failed to execute voice_installer.sh"

    echo -e "${GREEN}Piper installation complete.${NC}"

    # Install npm dependencies and start the application
    print_header "Installing npm Dependencies and Starting piper server"
    npm install .
    check_error "npm install failed"
    npm start
    check_error "npm start failed"
fi
