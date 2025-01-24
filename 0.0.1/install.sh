#!/bin/bash

BINARY_NAME="float16"
VERSION="0.0.3-beta.1"
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
    if command -v curl &> /dev/null; then
        curl -L -o "$INSTALL_PATH/$BINARY_NAME" "$DOWNLOAD_URL"
    elif command -v wget &> /dev/null; then
        wget -O "$INSTALL_PATH/$BINARY_NAME" "$DOWNLOAD_URL"
    else
        echo "Error: curl or wget required"
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
            echo "export PATH=\$PATH:$INSTALL_PATH" >> "$SHELL_RC"
            ;;
        windows)
            setx PATH "%PATH%;$INSTALL_PATH"
            ;;
    esac
}

main() {
    detect_platform
    download_binary
    install_binary
    update_path
    echo "Installation complete! Please restart your terminal."
}

main