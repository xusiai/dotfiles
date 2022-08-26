#!/bin/sh
session required /lib/security/pam_limits.so & 
setxkbmap se
xrdb merge $HOME/.config/dwm/.Xresources
ksuperkey -e 'Super_L=Super_L|F1'
xfce4-power-manager &
pipewire &
pipewire-pulse &
easyeffects --gapplication-service &
xset r rate 200 50 &
picom --config $HOME/.config/dwm/picom/picom.conf &
feh --bg-scale --randomize --recursive $HOME/.local/share/wallpapers/ &
/usr/libexec/polkit-gnome-authentication-agent-1 &
mconnect -d &
mpd &
mpDris2 &
~/.config/dwm/scripts/./bar.sh &
while type dwm >/dev/null; do dwm && continue || break; done
