if (( $+commands[brew] )); then
  eval "$(brew shellenv)"
else
  for brew_path in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew \
    "$HOME/.linuxbrew/bin/brew"; do
    [[ -x "$brew_path" ]] && { eval "$("$brew_path" shellenv)"; break; }
  done
  unset brew_path
fi
