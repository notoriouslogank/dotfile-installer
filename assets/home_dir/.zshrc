export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$HOME/snap/:$HOME/scripts:$PATH
export MANPATH="/usr/local/man:$MANPATH"
export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8

plugins=(git)
source $ZSH/oh-my-zsh.sh
ZSH_THEME="aussiegeek"
zstyle ':omz:update' mode disabled

alias ls="lsd"
alias lsa="lsd -a"
alias lsl="lsd -al"
