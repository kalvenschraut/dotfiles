# ~/.bashrc: executed by bash(1) for non-login shells.
# vim: ft=sh ts=4

[ -z "$PS1" ] && return

case ${TERM} in
	xterm*|rxvt*|gnome*|konsole*)
		export TERM=xterm-256color
		export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
		;;
	screen*)
		export TERM=screen-256color
		export PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"'
		;;
esac


parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ on \1/'
}

source_dir() {
	local dir="$1"
	if [[ -d $dir ]]; then
		local conf_file
		for conf_file in "$dir"/*; do
			if [[ -f $conf_file && $(basename $conf_file) != 'README' ]]; then
				source "$conf_file"
			fi
		done
	fi
}


source_dir ~/.bash.d/local/before
source_dir ~/.bash.d
source_dir ~/.bash.d/local/after

if [ -f ~/.ssh/agent ]; then
        alias restart-ssh-agent='ssh-agent > ~/.ssh/agent; source ~/.ssh/agent; ssh-add'
fi

if [ -e ~/.ssh/agent ]; then
        test -z "$(pidof ssh-agent)" && echo "echo \"No agent is running\"" > ~/.ssh/agent
        source ~/.ssh/agent
fi;

# ssh aliases
alias ssh-eg='ssh -A kalvens@2620:9d:4000:72:136c:fa8:54b:9be1'
alias ssh-ws='ssh kalvens@192.168.1.72'

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\e[01;36m$(parse_git_branch)\e\]\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ssh-egram='ssh -A 192.168.50.50'

#export DISPLAY=localhost:0.0

# start ssh agent if not running
if [ -z "$SSH_AUTH_SOCK" ] ; then
		eval `ssh-agent -s`
		ssh-add
fi

#current alternative screen directory if the normal one doesn't exist
ALTSCREENDIR=$HOME/.screen
if [ ! -d "/var/run/screen" ]; then
	if [ ! -d $ALTSCREENDIR ]; then
		mkdir $ALTSCREENDIR && chmod 700 $ALTSCREENDIR
	fi
	export SCREENDIR=$HOME/.screen
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias ipv6-randip='dd if=/dev/urandom bs=8 count=1 2>/dev/null | od -x -A n | sed -e "s/^ //" -e "s/ /:/g" -e "s/:0*/:/g" -e "s/^0*//"'
