# From /etc/zshenv
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Default Applications
export EDITOR="nvim"
export VISUAL="cat"
export PAGER="less"

# GPG
export GPG_TTY=$(tty)

# Starship
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"