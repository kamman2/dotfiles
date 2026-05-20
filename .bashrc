# ~/.bashrc: executed by bash(1) for non-login shells.
# AI-assisted development using Claude Sonnet 4.6

# ─── Guard: interactive shells only ──────────────────────────────────────────
case $- in
    *i*) ;;
      *) return;;
esac

# ─── History ──────────────────────────────────────────────────────────────────
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

# ─── Shell options ────────────────────────────────────────────────────────────
shopt -s checkwinsize   # keep LINES/COLUMNS current after each command
# shopt -s globstar     # enable ** glob (uncomment if needed)

# ─── Pager ───────────────────────────────────────────────────────────────────
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ─── Prompt ───────────────────────────────────────────────────────────────────
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# ─── Host-specific prompt colors ────────────────────────────────────────────
# Each remote machine gets a distinct prompt color for instant visual ID

_get_host_prompt_color() {
    case "$(hostname)" in
        m-c7010) echo "01;91" ;;   # Bright red
        Z790-5090-ubuntu) echo "01;96" ;;   # Bright cyan
        *) echo "01;32" ;;   # Default green
    esac
}

if [ "$color_prompt" = yes ]; then
    _HOST_COLOR=$(_get_host_prompt_color)
    PS1='${debian_chroot:+($debian_chroot)}\[\033[${_HOST_COLOR}m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    unset _HOST_COLOR
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

# ─── Colour support ───────────────────────────────────────────────────────────
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ─── Aliases ──────────────────────────────────────────────────────────────────
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# ─── Bash completion ──────────────────────────────────────────────────────────
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ─── PATH ─────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.lmstudio/bin:$PATH"
export PATH="$HOME/bin/pi-tools:$PATH"

# ─── pi wrapper ───────────────────────────────────────────────────────────────
# Intercepts `pi go fetch` and routes to pi-go-fetch; all other args pass through.
pi() {
    if [[ "$1" == "go" ]] && [[ "$2" == "fetch" ]]; then
        shift 2
        exec pi-go-fetch "$@"
    else
        exec "$HOME/.npm-global/bin/pi" "$@"
    fi
}

# ─── tmux auto-attach ─────────────────────────────────────────────────────────
# Attaches to (or creates) the 'main' session on login.
# Uses a non-exec pattern so exiting tmux returns to a plain shell rather
# than terminating the process entirely.
if [ -z "$TMUX" ]; then
    if tmux has-session -t main 2>/dev/null; then
        tmux attach-session -t main
    else
        tmux new-session -s main
    fi
fi
export PATH="$HOME/go/bin:$PATH"
