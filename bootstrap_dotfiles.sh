#!/bin/bash
# bootstrap_dotfiles.sh
# One-time setup: injects the source line for injection.sh into ~/.bashrc

BASHRC="$HOME/.bashrc"
DOTFILES_DIR="$HOME/dotfiles"
INJECTION_SNIPPET='[ -f "$HOME/dotfiles/injection.sh" ] && source "$HOME/dotfiles/injection.sh"'

echo "Bootstrapping dotfiles..."

if ! grep -Fq "$INJECTION_SNIPPET" "$BASHRC"; then
  {
    echo ""
    echo "# Load dotfiles injection"
    echo "$INJECTION_SNIPPET"
  } >> "$BASHRC"
  echo "Injected dotfiles source snippet into $BASHRC"
else
  echo "Dotfiles source snippet already present in $BASHRC"
fi

echo "Done! Run 'source ~/.bashrc' or restart your shell to apply."
