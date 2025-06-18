#!/bin/bash
# core-utils.sh
# Core Helper functions

# This regex pattern finds function names in shell scripts. It looks for
# strings that look like `function_name()` and ignores those starting with `_`.
# \K resets the start of the reported match, so we only get the function name itself.
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