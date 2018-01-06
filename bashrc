export LANG=en_AU.UTF-8

export EDITOR=nvim
alias vim=nvim

# ls and grep colours
alias ls='ls -FG'
alias grep='grep --color=auto'

# case insensitive auto complete
bind 'set completion-ignore-case on'

function hash_to_colour {
    tput setaf $(echo $1 | sum | awk -v ncolors=$(infocmp -1 | expand | sed -n -e "s/^ *colors#\([0-9][0-9]*\),.*/\1/p") 'ncolors>1 {print 1 + ($1 % (ncolors - 1))}')
}

COLOUR_BLACK=$(tput setaf 0)
COLOUR_RED=$(tput setaf 1)
COLOUR_GREEN=$(tput setaf 2)
COLOUR_YELLOW=$(tput setaf 3)
COLOUR_BLUE=$(tput setaf 4)
COLOUR_MAGENTA=$(tput setaf 5)
COLOUR_CYAN=$(tput setaf 6)
COLOUR_WHITE=$(tput setaf 7)
COLOUR_GREY=$(tput setaf 8)
TEXT_BOLD=$(tput bold)
TEXT_UNDERLINE=$(tput smul)
TEXT_RESET=$(tput sgr0)
HOSTNAME_COLOUR="$(hash_to_colour $(hostname))"

# vi mode
bind 'set editing-mode vi'
bind 'set keymap vi-command'
bind 'set show-mode-in-prompt on'
bind "set vi-ins-mode-string \"\1$COLOUR_BLUE\2(+)\1$TEXT_RESET\2\""
bind "set vi-cmd-mode-string \"\1$COLOUR_MAGENTA\2(>)\1$TEXT_RESET\2\""

function git_branch_or_empty {
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -z $branch ]; then
        # no git repo
        echo ""
    else
        # in a repo
        local repo=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename)
        local colour=$(hash_to_colour $repo)
        # check for uncommitted changes
        git diff-index --quiet HEAD -- || branch+="*"
        echo -e "\x01$colour\x02${branch}\x01$TEXT_RESET\x02 "
    fi
}

PS1=" "
PS1+="\u\[$HOSTNAME_COLOUR\]@\h\[$TEXT_RESET\] "
PS1+="\w "
PS1+='$(git_branch_or_empty)'
PS1+="$ "

function timer_start {
    if [ -z $timer ]; then
        timer=${timer:-$SECONDS}
    else
        return
    fi
}

function timer_stop {
  LAST_TIME=$(($SECONDS - $timer))
  unset timer
}

trap 'timer_start' DEBUG

function prompt_command {
    local code="$?"
    timer_stop
    local output=""
    if [ $LAST_TIME -gt 1 ]; then
        local s=$LAST_TIME
        local h=$((s/3600))
        s=$((s-(h*3600)))
        local m=$((s/60))
        s=$((s-(m*60)))
        local str=""
        (( $h == 0 )) || str+="${h}h "
        (( $m == 0 )) || str+="${m}m "
        (( $s == 0 )) || str+="${s}s "
        str=${str% }
        output+="$COLOUR_YELLOW($str)$TEXT_RESET "
    fi
    if [ $code != 0 ]; then
        output+="$COLOUR_RED[$code]$TEXT_RESET"
    fi
    [ -z "$output" ] || echo $output
}

PROMPT_COMMAND=prompt_command

