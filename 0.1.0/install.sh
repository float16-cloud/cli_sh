#!/bin/bash

BINARY_NAME="float16"
VERSION="0.1.0"
BASE_URL="https://float16-cli-executables.s3.ap-southeast-1.amazonaws.com"

# Detect OS and Architecture
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    
    case "$OS" in
        Linux)     OS="linux" ;;
        Darwin)    OS="mac" ;; # macOS
        CYGWIN*|MINGW*|MSYS*) OS="win" ;;
        *)         echo "Unsupported OS: $OS"; exit 1 ;;
    esac

    case "$ARCH" in
        x86_64)  ARCH="x64" ;;
        aarch64) ARCH="arm64" ;;
        arm64)   ARCH="arm64" ;;
        *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
}

# Installation paths per OS
get_install_path() {
    case "$OS" in
        linux)   echo "/usr/local/bin" ;;
        mac)  echo "/usr/local/bin" ;;
        windows) echo "$HOME/AppData/Local/Programs/$BINARY_NAME" ;;
    esac
}

# Download binary
download_binary() {
    INSTALL_PATH="$(get_install_path)"
    DOWNLOAD_URL="$BASE_URL/float16-cli-$OS-$ARCH-$VERSION"
    if [ "$OS" = "win" ]; then
        DOWNLOAD_URL="$DOWNLOAD_URL.exe"
    fi

    echo "Downloading from: $DOWNLOAD_URL"
    if ! sudo mkdir -p "$INSTALL_PATH"; then
        echo "Error: Failed to create installation directory"
        exit 1
    fi

    if command -v curl &> /dev/null; then
        if ! sudo curl -L -o "$INSTALL_PATH/$BINARY_NAME" "$DOWNLOAD_URL"; then
            echo "Error: Failed to download binary using curl"
            exit 1
        fi
    elif command -v wget &> /dev/null; then
        if ! sudo wget -O "$INSTALL_PATH/$BINARY_NAME" "$DOWNLOAD_URL"; then
            echo "Error: Failed to download binary using wget"
            exit 1
        fi
    else
        echo "Error: curl or wget required"
        exit 1
    fi

    # Add executable permissions for all users
    if [ "$OS" != "win" ]; then
        if ! sudo chmod 755 "$INSTALL_PATH/$BINARY_NAME"; then
            echo "Error: Failed to set executable permissions"
            exit 1
        fi
    fi

    # Verify the binary exists and is executable
    if [ ! -f "$INSTALL_PATH/$BINARY_NAME" ]; then
        echo "Error: Binary not found after installation"
        exit 1
    fi
}


# Update PATH
update_path() {
    INSTALL_PATH="$(get_install_path)"
    
    case "$OS" in
        linux|mac)
            SHELL_RC="$HOME/.bashrc"
            [ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"
            if ! echo "export PATH=\$PATH:$INSTALL_PATH" >> "$SHELL_RC"; then
                echo "Error: Failed to update PATH in shell configuration"
                exit 1
            fi
            ;;
        windows)
            if ! setx PATH "%PATH%;$INSTALL_PATH"; then
                echo "Error: Failed to update PATH in Windows"
                exit 1
            fi
            ;;
    esac
}

main() {
    if ! detect_platform; then
        echo "Error: Failed to detect platform"
        exit 1
    fi
    
    echo "Installing float16 version $VERSION for $OS-$ARCH..."
    
    if ! download_binary; then
        echo "Error: Installation failed during binary download"
        exit 1
    fi
    
    if ! update_path; then
        echo "Error: Installation failed during PATH update"
        exit 1
    fi
    
    echo "Installation complete! Please restart your terminal."
}

main