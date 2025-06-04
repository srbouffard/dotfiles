# prompt.sh — smart prompt label + git branch + title

# Use PROMPT_USER_LABEL if defined, else fallback to $USER or `whoami`
PROMPT_USER_LABEL="${PROMPT_USER_LABEL:-${USER:-$(whoami)}}"

# Source Git prompt support if available
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
elif [ -f /etc/bash_completion.d/git-prompt ]; then
    source /etc/bash_completion.d/git-prompt
fi

# Build PS1 with Git and colors
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]'"$PROMPT_USER_LABEL"'\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " \[\033[01;33m\](%s)\[\033[00m\]")\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}'"$PROMPT_USER_LABEL"':\w$(__git_ps1 " (%s)")\$ '
fi

# Set terminal window title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}$PROMPT_USER_LABEL: \w\a\]$PS1"
    ;;
esac