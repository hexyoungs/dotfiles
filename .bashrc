PS1='[\u@\h \W]\$ '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

alias pc='proxychains4'

eval "$(starship init bash)"

export PATH="$HOME/miniconda3/bin:$HOME/.yarn/bin/:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"
export VAGRANT_DEFAULT_PROVIDER=libvirt

alias pg-local='pgcli postgres://postgres:8e01d6f60c7a846c38d5f99cf3f53383@localhost:5432/baseone'

alias set-proxy='export http_proxy="socks5://127.0.0.1:1080";export https_proxy="socks5://127.0.0.1:1080"'
alias update-grub='grub-mkconfig -o /boot/grub/grub.cfg'

export GO111MODULE=on

alias rust-musl-builder='docker run --rm -it -v "$(pwd)":/home/rust/src ekidd/rust-musl-builder'

alias sync-time='sudo /usr/sbin/ntpdate pool.ntp.org' # need ntp package

alias disable-hibernate='sudo systemctl mask hibernate.target hybrid-sleep.target'
alias enable-hibernate='sudo systemctl unmask hibernate.target hybrid-sleep.target'
