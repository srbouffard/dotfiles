# functions.sh
# Custom functions, aliases, and shell tweaks

alias ll='ls -alF'
alias gs='git status'

# Source multipass-utils.sh or other scripts here if not sourced globally
if [ -f "$HOME/dotfiles/multipass-utils.sh" ]; then
  source "$HOME/dotfiles/multipass-utils.sh"
fi

# Other functions...
