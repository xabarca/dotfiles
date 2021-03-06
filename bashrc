alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -l'
alias myip='curl ipinfo.io/ip'
alias q="exit"
alias nnn="nnn -de"
alias mem='ps -u $USER -o pid,%mem,comm | sort -b -k2'

if [ $(id -u) -eq 0 ];
then # you are root, set red colour prompt
    PS1="\e[1;31m\w # \e[m"
else # normal
   PS1="\e[1;34m\w\e[m\e[1;35m\$ \e[m"
fi



# -----------------------------
#   nnn file manager configs
#------------------------------
n () {
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    nnn -R "$@"
    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}
EDITOR="vim"
VISUAL="vim"
export NNN_BMS='b:~/bin;d:~/downloads;c:~/.config;g:/opt/git;t:/tmp;p:~/pictures'
export NNN_PLUG='v:_|vim $nnn*'
export NNN_USE_EDITOR=1
export NNN_OPENER=~/bin/nnnopen
export NNN_COLORS="4356"

~/bin/colors.sh
