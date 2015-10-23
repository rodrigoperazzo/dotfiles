export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h\[\033[m\]:\[\033[0m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export PATH=$PATH:~/Library/Android/sdk/platform-tools/

alias ls='ls -GFh'
alias grep='grep --color'
alias rsync='rsync --rsh="ssh" -av --partial --progress'
