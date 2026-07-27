alias s='source ~/.config/zsh/.zshrc'

# Better ls
alias ls='eza --icons auto'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons --git'

# Tree view
alias tree='eza --tree --icons'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# Better cat
# alias cat='bat'

# AI
alias claudeai="claude --model global.anthropic.claude-opus-4-8 --enable-auto-mode"
alias codexai="codex --yolo -c 'model_reasoning_effort="high"' -c 'model_reasoning_summary="detailed"' -c model_supports_reasoning_summaries=true"