# functions.sh
# Custom functions, aliases, and shell tweaks

# Navigation Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Git Aliases
alias gs='git status'
alias gco='git checkout'
alias gb='git branch'
alias gp='git pull'
alias gP='git push'
alias gd='git diff'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Add this to your functions.sh file

# A function to add all changes, commit with a message, and push.
# Usage: gacp "Your commit message"
gacp() {
  # Check if a commit message was provided
  if [ -z "$1" ]; then
    echo "Error: A commit message is required."
    echo "Usage: gacp \"Your commit message\""
    return 1
  fi

  echo "➡️  Adding all changes..."
  git add --all

  echo "➡️  Committing with message: \"$1\"..."
  git commit -m "$1"

  echo "➡️  Pushing to remote..."
  git push
}

# Source multipass-utils.sh
if [ -f "$HOME/dotfiles/multipass-utils.sh" ]; then
  source "$HOME/dotfiles/multipass-utils.sh"
fi

# Source core utils
if [ -f "$HOME/dotfiles/core-utils.sh" ]; then
  source "$HOME/dotfiles/core-utils.sh"
fi
