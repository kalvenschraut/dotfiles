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
alias ssh-ws='ssh kalvens@2620:9d:4000:1:eb18:2e99:4914:4150'

export DISPLAY=localhost:0.0

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
