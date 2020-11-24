export LANG=en_US.UTF-8
export LC_CTYPE=zh_CN.UTF-8
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export EDITOR="nvim"
export TERMINAL="st"
export BROWSER="chrome"

setxkbmap -option ctrl:nocaps &
xmodmap -e "keycode 37=" &
xset r rate 300 50 &

fcitx-autostart &

~/.config/scripts/pegas_autostart &
~/.config/scripts/bg_autostart &

kill "$(pgrep -f bar.sh)"
~/.config/scripts/bar.sh &

pkill sxhkd
sxhkd &

xrdb ~/.Xresources
exec dwm
