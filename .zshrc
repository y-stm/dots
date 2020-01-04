# -*- orgstruct-heading-prefix-regexp: "####" -*-
# zshrc : ログインシェル、インタラクティブシェル起動時に実行

# 大体の設定は/etc/zsh/zshrcで行われている
# zshrc : ログインシェル、インタラクティブシェル起動時に実行
# zshenv : ログインシェル、インタラクティブシェル、シェルスクリプト実行時に実行
# zprofile : ログインシェル時に実行
# zlogin : ログインシェル時に実行
# zlogout : ログインシェルをzshで起動して、ログアウトするときに実行

##### zsh settings
autoload colors
setopt list_packed
setopt nolistbeep
setopt extendedglob
setopt autocd
# expand variable in PROMPT for git status
setopt prompt_subst
# emacs-like keybinds
bindkey -e
set +x
# Compilation
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
fpath=(~/.zsh_comp $fpath)
# compinit enables to word compilation for arguments.
autoload -U compinit
compinit
# HISTFILE	: where history file in it
# HISTSIZE	: size of history (in memory)
# SAVEHIST	: size of history (in HISTFILE)
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=1000000
setopt hist_ignore_all_dups
setopt share_history
setopt appendhistory
# window title or screen title changes
title () {
	  out=$(echo -E $*)
	  case $TERM in
        #       Instead of belowing window rename, `tmux set-window-option automatic-rename'
        #		screen*)
        #			# zsh's quoting for escape sequence, which doesn't expand
        #			# variables.
        #			print -nR $'\ek'${out}$'\a' # equal to echo -ne
        #			;;
		    xterm*|rxvt*|dvtm*|st*)
			      print -nR $'\e]0;'${out}$'\a'
	  esac
}

precmd () {
	  dir=$(echo $PWD | sed -e "s%$HOME%~%")
	  case $TERM in
		    screen*)
			      title $dir@$HOST
			      ;;
		    xterm*|rxvt*|dvtm*|st*)
			      title $dir@$HOST
	  esac
}

preexec () {
	  emulate -L zsh
	  local -a cmd;
	  cmd=(${(z)1}) # split $1 into array. see man zshexpn
	  title $cmd
	  #local -a cmd; cmd=(${(z)1}) title "$cmd[1]:t" "$cmd[2,-1]"
}

#### Prompt
# define rgb color and black
local cg=$(echo "\e[32m")
local cr=$(echo "\e[31m")
local cb=$(echo "\e[34m")
local b=$(echo "\e[0m")
# Check my confirmed list. If other terminals are capable colors, add it
#case $TERM in
#		xterm*|rxvt*|linux*|screen*|st*|tmux*|dvtm*|alacritty*|dumb)
#		;;
#		*)
#			  unset cg cr cb b
#esac
# Change color name on SSH
if [ z=z$SSH_CONNECTION ]; then
# defualt color
		local _cUser=${cg}
		local _cHost=${cg}
		local _cDir=${cr}
else
# SSH color
		local _cUser=${cb}
		local _cHost=${cg}
		local _cDir=${cr}
    export TERM=rxvt # TODO :: why this is required?
    echo SSH Connection is \"${SSH_CONNECTION}\"
fi
local _user=${_cUser}${USER}${b}
local _host=${_cHost}${HOST}${b}
local _dir="${_cDir}%~${b}"
# add virtual terminal sign
case $TERM in
    dvtm*|tmux*|screen*)
        local _virt=" $TERM "
        ;;
esac
# to use __git_ps1, source git-prompt.sh
source /usr/share/git/git-prompt.sh
local _line1="[${_shellname+${_shellname}:}${_user}@${_host}][${_dir}]${_virt}\$(__git_ps1)"
local _line2="└─>"
export PROMPT=$(echo ${_line1}; echo ${_line2})

#### PATH
# `-EOF` is used for here documents ignoreing heading spaces.
local _PATH=$(tr $IFS ':' <<-EOF
      ${PATH}/bin
      ${PATH}/.local/bin
      ${PATH}/.cargo/bin
      ${PATH}/.luna/bin
      ${PATH}/.roswell/bin
      ${PATH}/.npm-global/bin
      ${PATH}/.yarn/bin
EOF
      )
# $_PATH contains : at last, so no : required to concat $PATH
export PATH=$_PATH$PATH

#### alias
alias ls='ls --color=auto'
alias less='less -R'
alias pacman='pacman --color=auto'
alias yay='yay --color=auto'
alias config='/usr/bin/git --git-dir=${HOME}/dots --work-tree=${HOME}'

#### misc
# dircolor
eval `dircolors -b`
# chiicken scheme
export CHICKEN_REPOSITORY="${HOME}/programming/scheme/chicken-eggs"
export CHICKEN_DOC_REPOSITORY="${HOME}/programming/scheme/chicken-docs"
# gauche
export GAUCHE_LOAD_PATH=~/programming/scheme/gauche
alias gosh='gosh -r7'
# Java
export _JAVA_OPTIONS="\
 -Dawt.useSystemAAFontSettings=on \
 -Dsun.java2d.xrender=true \
 -Dswing.aatext=true \
 -Dsun.java2d.pmoffscreen=true"
# Lua
eval $(luarocks path --bin)
# man with highlighting
man() {
	  env LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		    LESS_TERMCAP_md=$(printf "\e[1;31m") \
		    LESS_TERMCAP_me=$(printf "\e[0m") \
		    LESS_TERMCAP_se=$(printf "\e[0m") \
		    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		    LESS_TERMCAP_ue=$(printf "\e[0m") \
		    LESS_TERMCAP_us=$(printf "\e[1;32m") \
		    man -P less "$@"
}
# OPAM
source ${HOME}/.opam/opam-init/init.zsh > /dev/null 2>&1

#### Utils
rxvt-title () {
	  echo "\033]2;$@\007"
}
dlclean () {
    find ${HOME}/sync/t -type f -regex '\(.*[tT][xX][tT]\)\|\(.*[uU][rR][lL]\)\|\(.*[dD][bB]\)\|\(.*\.\..*\)' -exec rm {} \;
}
novzip () {
	  # zip all directories starts with [
	  find ./ -maxdepth 1 -type d -regex './\[.*' |parallel zip -9 "{}.zip" -r {}
}
