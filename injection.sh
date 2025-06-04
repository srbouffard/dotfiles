#!/bin/bash
# injection.sh - centralized dotfiles environment setup

# Source environment variables
if [ -f "$HOME/dotfiles/env.sh" ]; then
  source "$HOME/dotfiles/env.sh"
fi

# Source functions, aliases, and helpers
if [ -f "$HOME/dotfiles/functions.sh" ]; then
  source "$HOME/dotfiles/functions.sh"
fi

# Source prompt
if [ -f "$HOME/dotfiles/prompt.sh" ]; then
  source "$HOME/dotfiles/prompt.sh"
fi

