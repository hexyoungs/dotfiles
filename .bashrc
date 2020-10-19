PS1='[\u@\h \W]\$ '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

alias ls='exa'
alias pc='proxychains4'

eval "$(starship init bash)"

export PATH="/home/hexyoungs/miniconda3/bin:/home/hexyoungs/.yarn/bin/:$PATH"

alias pg-local='pgcli postgres://postgres:8e01d6f60c7a846c38d5f99cf3f53383@localhost:5432/baseone'
