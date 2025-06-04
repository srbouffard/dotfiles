#!/bin/bash
# core-utils.sh
# Core Helper functions

# List all function names defined in your dotfiles repo, ignore internal methods that start with `_`
_dotfiles_functions_list() {
  grep -rhoP '^\s*(function\s+)?\K[a-zA-Z_][a-zA-Z0-9_]*(?=\s*\(\))' ~/dotfiles/*.sh 2>/dev/null | grep -v '^_' | sort -u
}

# Conditionally enable FZF Ctrl-T integration
if [[ "${ENABLE_DOTFILES_FZF_CTRL_T:-0}" == "1" ]]; then
  if command -v fzf >/dev/null 2>&1; then
    export FZF_CTRL_T_COMMAND='_dotfiles_functions_list'
    
    # Source fzf key bindings to activate Ctrl-T
    if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
      source /usr/share/doc/fzf/examples/key-bindings.bash
    else
      echo "fzf key bindings not found at /usr/share/doc/fzf/examples/key-bindings.bash"
    fi
  else
    echo "fzf not found: skipping dotfiles Ctrl-T integration"
  fi
fi
