# vim: ft=sh ts=4

[ -z "$PS1" ] && return

shopt -s globstar
export LIBGL_ALWAYS_INDIRECT=1

case ${TERM} in
xterm* | rxvt* | gnome* | konsole*)
	export TERM=xterm-256color
	export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
	;;
screen*)
	export TERM=screen-256color
	export PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"'
	;;
esac

parse_git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ on \1/'
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

gfbs() {
	test -z "$1" && {
		echo "Please provide the bugfix name"
		return
	}
	git fetch -p
	local current_release_branch="$(git branch -a | grep -E 'remotes.*origin.*release' | sed 's%remotes/origin/%%' | sort | tail -n1 | xargs)"
	test -z "$current_release_branch" && {
		echo "Could not find the current release branch"
		return
	}
	git checkout "$current_release_branch"
	git flow bugfix start "$1" "$current_release_branch"
}

clean-git-release-branches() {
	git fetch --all -p
	local current_release_branch="$(git branch -a | grep -E 'remotes.*origin.*release' | sed 's%remotes/origin/%%' | sort | tail -n1 | xargs)"
	test -z "$current_release_branch" && {
		echo "Could not find the current release branch"
		return
	}
	local old_release_branches="$(git branch -lr | grep -v ".*/$current_release_branch" | grep 'release/' | awk '{print $1}')"
	for branch in $old_release_branches; do
		git push --delete "${branch%%/*}" "${branch#*/}"
	done
}

ssh-port-forward() {
	test -z "$1" && {
		echo "Please provide port to forward"
		return
	}
	ssh -L "$1:localhost:$1" -N kalvens@kalvens.rtvision.com
}

source_dir ~/.bash.d/local/before
source_dir ~/.bash.d
source_dir ~/.bash.d/local/after

if [[ -f ~/.secrets ]]; then
	source ~/.secrets
fi

# ssh aliases
alias ssh-vm='ssh -A kalvens@2620:9d:4000:72:136c:fa8:54b:9be1'
alias ssh-ws='ssh kalvens@192.168.1.72'

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
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

function color_prompt {
	# need \[ and \] wrapping colors so correct width is figured out by terminal
	# \033[ is how to specify bash color
	# \033[32m is a color i.e. green see https://dev.to/ifenna__/adding-colors-to-bash-scripts-48g4
	# \033[01;32m adds bold font weight see above link for codes
	# also colors and fonts persist until changed again.. so need the reset color back to normal at the end
	local USER_HOST="\[\033[01;32m\]\u@\h"
	local CURRENT_LOCATION="\[\033[34m\]\w"
	local GIT_BRANCH='$(git branch 2> /dev/null | grep -e ^* | sed "s/\*/ on/")'
	local GIT_PROMPT="\[\033[00;96m\]$GIT_BRANCH"
	local PROMPT_TAIL="\[\033[01;00m\] $"
	local RESET_COLOR="\[\033[00;00m\]"
	echo "$USER_HOST $CURRENT_LOCATION$GIT_PROMPT$PROMPT_TAIL$RESET_COLOR "
}

if [ "$color_prompt" = yes ]; then
	PS1=$(color_prompt)
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;

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

alias ssh-vm='ssh -A 192.168.50.50'

#current alternative screen directory if the normal one doesn't exist
ALTSCREENDIR=$HOME/.screen
if [ ! -d "/var/run/screen" ]; then
	if [ ! -d $ALTSCREENDIR ]; then
		mkdir $ALTSCREENDIR && chmod 700 $ALTSCREENDIR
	fi
	export SCREENDIR=$HOME/.screen
fi

alias ipv6-randip='dd if=/dev/urandom bs=8 count=1 2>/dev/null | od -x -A n | sed -e "s/^ //" -e "s/ /:/g" -e "s/:0*/:/g" -e "s/^0*//"'

bind -f ~/.inputrc
export LAUNCH_EDITOR="$HOME/launch_editor"
alias nvim-server="nvim --listen ~/.cache/nvim/server.pipe"

# pnpm
export PNPM_HOME="/home/kalvens/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

. "$HOME/.cargo/env"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# neovim nightly build
export PATH="/opt/nvim/bin:$PATH"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
. "$HOME/.cargo/env"
export PATH="$HOME/go/bin:$PATH"

# opencode
export PATH=/home/kalvens/.opencode/bin:$PATH
