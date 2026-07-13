#!/usr/bin/env bash

set -e

echo "System setup starting..."

# 1. Detect OS and install Stow
if ! command -v stow &> /dev/null; then
    echo "GNU Stow not found. Installing..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Ubuntu / Debian
        sudo apt-get update
        sudo apt-get install -y stow
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if ! command -v brew &> /dev/null; then
            echo "Homebrew is required but not installed. Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://githubusercontent.com)"
            
            # Ensure brew is in PATH for the rest of this script execution
            if [[ -f /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f /usr/local/bin/brew ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        brew install stow
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
else
    echo "GNU Stow is already installed."
fi

# 2. Sync to script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# 3. Stow configuration folders
echo "Stowing configurations..."
stow .

echo "Stowing complete."
