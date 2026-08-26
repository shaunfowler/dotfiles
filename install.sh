#!/usr/bin/env bash

set -euo pipefail

FORCE=false

usage() {
    echo "Usage: $0 [-f|--force]"
    echo "  -f, --force  Back up regular files that conflict with Stow targets"
}

while (($# > 0)); do
    case "$1" in
        -f|--force)
            FORCE=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

echo "System setup starting..."

# 1. Detect OS and install deps

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Ubuntu / Debian
    sudo apt-get update
    sudo apt-get install -y stow git curl fd-find fzf zoxide bat eza

    # Debian-based distributions rename these commands to avoid package-name
    # collisions. Provide the names used by the shell configuration.
    mkdir -p "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
    if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    fi

    if ! command -v starship >/dev/null 2>&1; then
        echo "Installing Starship..."
        curl --fail --silent --show-error --location https://starship.rs/install.sh \
            | sh -s -- --yes --bin-dir "$HOME/.local/bin"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is required but not installed. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Ensure brew is in PATH for the rest of this script execution
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    brew install stow fd fzf zoxide bat eza starship
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# 2. Sync to script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# 3. Stow configuration folders
echo "Stowing configurations..."
if [[ "$FORCE" == true ]]; then
    STOW_PLAN=""
    if STOW_PLAN="$(stow --simulate --verbose=2 . --target="$HOME" 2>&1)"; then
        :
    else
        CONFLICTS=()
        UNSUPPORTED_CONFLICT=false

        while IFS= read -r line; do
            if [[ "$line" == CONFLICT*'existing target is neither a link nor a directory: '* ]]; then
                conflict="${line##*: }"
                if [[ -z "$conflict" || "$conflict" == /* || "$conflict" == ".." || "$conflict" == ../* || "$conflict" == */../* || "$conflict" == */.. ]]; then
                    echo "Refusing unsafe conflict path: $conflict" >&2
                    exit 1
                fi
                CONFLICTS+=("$conflict")
            elif [[ "$line" == CONFLICT* ]]; then
                UNSUPPORTED_CONFLICT=true
            fi
        done <<< "$STOW_PLAN"

        if [[ "$UNSUPPORTED_CONFLICT" == true || ${#CONFLICTS[@]} -eq 0 ]]; then
            printf '%s\n' "$STOW_PLAN" >&2
            echo "Force mode cannot safely resolve every Stow conflict." >&2
            exit 1
        fi

        DOTFILES_BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)-$$"
        mkdir -p "$DOTFILES_BACKUP_DIR"
        echo "Backing up conflicting targets to $DOTFILES_BACKUP_DIR"

        for conflict in "${CONFLICTS[@]}"; do
            target="$HOME/$conflict"
            if [[ ! -e "$target" && ! -L "$target" ]]; then
                echo "Conflict disappeared before it could be backed up: $target" >&2
                exit 1
            fi
            backup_target="$DOTFILES_BACKUP_DIR/$conflict"
            if [[ "$conflict" == */* ]]; then
                mkdir -p "$DOTFILES_BACKUP_DIR/${conflict%/*}"
            fi
            mv -- "$target" "$backup_target"
            echo "  $target -> $backup_target"
        done
    fi
fi

stow . --target="$HOME"

echo "Linking the Zsh environment bootstrap..."
if [[ ! -e "$HOME/.zshenv" && ! -L "$HOME/.zshenv" ]]; then
    ln -s ".config/zsh/.zshenv" "$HOME/.zshenv"
elif [[ ! "$HOME/.zshenv" -ef "$HOME/.config/zsh/.zshenv" ]]; then
    echo "WARNING: $HOME/.zshenv already exists and was left unchanged." >&2
    echo "Ensure it exports ZDOTDIR=$HOME/.config/zsh." >&2
fi

if ! command -v starship >/dev/null 2>&1; then
    echo "ERROR: Starship installation did not provide a starship executable." >&2
    exit 1
fi

echo "Complete."
