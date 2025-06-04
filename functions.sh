# functions.sh
# Custom functions, aliases, and shell tweaks

alias ll='ls -alF'
alias gs='git status'

# Source multipass-utils.sh
if [ -f "$HOME/dotfiles/multipass-utils.sh" ]; then
  source "$HOME/dotfiles/multipass-utils.sh"
fi

# Source core utils
if [ -f "$HOME/dotfiles/core-utils.sh" ]; then
  source "$HOME/dotfiles/core-utils.sh"
fi
