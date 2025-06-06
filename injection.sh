#!/bin/bash
# injection.sh - centralized dotfiles environment setup

# Source environment variables, always loaded first due to feature flags
if [ -f "$HOME/dotfiles/env.sh" ]; then
  source "$HOME/dotfiles/env.sh"
fi

# Source dependencies
if [ -f "$HOME/dotfiles/dependencies.sh" ]; then
  source "$HOME/dotfiles/dependencies.sh"
fi

# Source functions, aliases, and helpers
if [ -f "$HOME/dotfiles/functions.sh" ]; then
  source "$HOME/dotfiles/functions.sh"
fi

# Source prompt
if [ -f "$HOME/dotfiles/prompt.sh" ]; then
  source "$HOME/dotfiles/prompt.sh"
fi

sourceme() {
  source "$HOME/dotfiles/injection.sh"
}