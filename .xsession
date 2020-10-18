#!/bin/sh

[ -f "$HOME/.xprofile" ] && . ~/.xprofile

/usr/bin/start-pulseaudio-x11
/home/hexyoungs/.config/scripts/pegas_autostart &
/home/hexyoungs/.config/scripts/bg_autostart &

exec dwm
