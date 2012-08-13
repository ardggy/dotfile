#  .zshrc
# since 2009-01-30
#

# environment
PATH=${(j/:/)${(s/:/)PATH}%/}${PATH:+:}$HOME/bin
PATH=/usr/local/bin:$PATH

export TERM=xterm
export NODE_PATH=/usr/local/lib/node_modules
export EDITOR=emacsclient
export VISUAL=emacsclient
export GIT_PAGER=emacsclient

# byobu - tmux wrapper
export BYOBU_BACKEND=tmux
export BYOBU_CONFIG_DIR=${HOME}/.byobu

REPORTTIME=5
TIMEFMT="%J: %U+%s, %P CPU, %*E total"

# load my functions
[[ -f ~/.zfunc ]] && source ~/.zfunc

# if exist fortune
if [[ -n $(whence fortune) ]] fortune buront

# internal command help
if [[ -n $(alias run-help) ]];
autoload run-help

# autoload function
autoload zed
autoload -Uz zmv

# zsh modules
# zmodload zsh/sched
# zmodload zsh/zftp

# aliasing command
alias ls="ls -hF"
alias la="ls -a"
alias ll="ls -l"
alias lla="ll -a"
alias ldir="ls | grep '/$'"
alias where="command -v"
alias j="jobs -l"

alias du="du -h"
alias df="df -h"

alias screen="screen -U"

alias arc="(cd $HOME/opt/arc && /opt/local/bin/mzscheme -f as.scm)"
alias perl="perl -w"         # warning option (also gcc)
alias gcc="gcc -Wall -O0"	# and optimize (Level zero)

alias emacs="emacsclient -c -nw"
alias par="parallel"
alias seq="gseq"  # for Mac OS X

# keymap
#xmodmap ~/.xmodmap
#xmodmap ~/.xmodmap.user

# color
autoload -U colors; colors

# predict
autoload predict-on
autoload predict-off

# completion
autoload -U compinit && compinit

# zstyle
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matcheds for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' format '%BCompleting %d%b'
zstyle ':completion:*' group-name ';'

# vcs infomation
autoload -Uz vcs_info

# zstyle 'vcs_info:*' actionformats "String"
# zstyle 'vcs_info:*' formats 'String'
zstyle 'vcs_info:*' disable ALL
zstyle 'vcs_info:*' enable darks rcs git svn


# language
export LANG=ja_JP.UTF-8

# xprompt
RPROMPT="%{${fg[red]}%} %B20%D%b %{${fg[yellow]}%}<%T> %{${reset_color}%}"
PROMPT="%{${fg[yellow]}%}[%~] %{${reset_color}%}"
PROMPT2='%_%% '
SPROMPT='is %r correct? [n,y,a,e]: '

# key-bind
bindkey -e			# emacs-like key-binding
zstyle ':completion:*:default' menu select=1 # select with emacs' keybind

#bindkey -v			# vi-like key-binding

# smart insert
autoload smart-insert-last-word
zle -N insert-last-word smart-insert-last-word
zstyle ':insert-last-word' match '*([^[:space:]][[:alpha:]/\\]|[[:alpha:]/\\][^[:space:]])*'
bindkey '^]' insert-last-word

# history option
HISTFILE=~/.zsh_history
HISTSIZE=100000000
SAVEHIST=100000000

setopt hist_ignore_dups		# ignore duplication command history list
setopt share_history		# share command history data
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_reduce_blanks

# file glob option
setopt numeric_glob_sort	# sort filename as integer
setopt extended_glob

# set option
setopt auto_cd
setopt no_auto_remove_slash
setopt list_packed		# display compacked complete list
setopt auto_pushd		# memory previous directory
setopt ignore_eof
setopt correct
setopt no_list_beep
setopt no_flow_control
setopt short_loops
setopt brace_ccl
#setopt always_last_prompt

# historical back/forward search with linehead string binded to ^
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

zle -N predict-on
zle -N predict-off
bindkey "^Xp"	predict-on
bindkey "^X^p"	predict-off
# bindkey "^Tt" transpose-chars

local COMMAND=""
local COMMAND_TIME=""
function precmd () {
    vcs_info
    if [ "$COMMAND_TIME" -ne "0" ] ; then
        local d=`date +%s`
        d=`expr $d - $COMMAND_TIME`
        if [ "$d" -ge $REPORTTIME ] ; then
            COMMAND="$COMMAND "
            growlnotify -t "${${(s: :)COMMAND}[1]} finished." -m "$COMMAND ${d}sec."
        fi
    fi
    COMMAND="0"
    COMMAND_TIME="0"
}

function preexec () {
    COMMAND="${1}"
    if [ "`perl -e 'print($ARGV[0]=~m/ssh|^vi|^emacs/)' $COMMAND`" -ne 1 ] ; then
        COMMAND_TIME=`date +%s`
    fi
}

function rationalise-dot () {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+=/..
    else
        LBUFFER+=.
    fi
}

zle -N rationalise-dot
bindkey . rationalise-dot

source ~/.zsh/git-completion.bash

## Object oriented
source ~/.zsh/oo/oo.zsh
alias par=parallel
