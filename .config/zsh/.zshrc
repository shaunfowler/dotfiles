# Defaults are needed when this file is sourced directly instead of loaded by
# zsh after .zshenv.
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${ZDOTDIR:=$XDG_CONFIG_HOME/zsh}"
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_STATE_HOME ZDOTDIR

# History

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

mkdir -p "${HISTFILE:h}" "$XDG_CACHE_HOME/zsh"

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Shell behavior

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

# PATH
export PATH="$HOME/.local/bin:$PATH"

#
# Completion
#

# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata and silently skip insecure paths.
# Do not use -u here: it loads insecure completion directories.
compinit -i -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

# zoxide
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# fzf
if (( $+commands[fzf] )); then
  if fzf_init="$(fzf --zsh 2>/dev/null)"; then
    eval "$fzf_init"
  else
    # fzf versions packaged by some Linux distributions predate --zsh.
    [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] && \
      source /usr/share/doc/fzf/examples/completion.zsh
    [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] && \
      source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
  unset fzf_init
fi

# Starship
(( $+commands[starship] )) && eval "$(starship init zsh)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

#
# Modular config files
#

for config_file in fzf aliases bindings plugins prompt; do
  [[ -r "$ZDOTDIR/$config_file.zsh" ]] && source "$ZDOTDIR/$config_file.zsh"
done
unset config_file
