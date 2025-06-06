#!/bin/bash
# core-utils.sh
# Core Helper functions

# Define pattern to fetch all function names defined in your dotfiles repo, ignore internal methods that start with `_`
DOTFILES_GREP_PATTERN='^\s*(function\s+)?\K[a-zA-Z_][a-zA-Z0-9_]*(?=\s*\(\))'

# List all function names
_dotfiles_functions_list() {
  grep -rhoP "$DOTFILES_GREP_PATTERN" ~/dotfiles/*.sh 2>/dev/null | grep -v '^_' | sort -u
}

# Conditionally enable FZF Ctrl-T integration
if [[ "${ENABLE_DOTFILES_FZF_CTRL_T:-0}" == "1" ]]; then
  if command -v fzf >/dev/null 2>&1; then
    export FZF_CTRL_T_COMMAND="grep -rhoP \"$DOTFILES_GREP_PATTERN\" ~/dotfiles/*.sh 2>/dev/null | grep -v '^_' | sort -u"
  else
    echo "fzf not found: install via git clone"
  fi
fi