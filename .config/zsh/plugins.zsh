ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

_omzplugin_load() {
  local plugin_path="${ZPLUGINDIR}/ohmyzsh"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ohmyzsh ${1} plugin..."
    git clone --depth=1 "https://github.com/ohmyzsh/ohmyzsh" "$plugin_path" \
      || { echo "ERROR: failed to install ${1}" >&2; return 1; }
  fi
  source "${plugin_path}/plugins/${1}/${1}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
# _zplugin_load jeffreytse zsh-vi-mode # fucks with CTRL-R for fzf
_zplugin_load zdharma-continuum fast-syntax-highlighting

_omzplugin_load git