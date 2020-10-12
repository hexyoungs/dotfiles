export LANG=en_US.UTF-8
export LC_CTYPE=zh_CN.UTF-8
export XMODIFIERS=@im=SCIM
export GTK_IM_MODULE=scim
export QT_IM_MODULE=scim
export EDITOR="nvim"
export TERM="sakura"
export BROWSER="firefox"

setxkbmap -option ctrl:nocaps &
xmodmap -e "keycode 37=" &
xset r rate 300 50 &

scim -d
exec spectrwm
