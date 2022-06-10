#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xrdb -merge "$HOME/.Xresources"
#xrandr --output DP-2 --mode 2560x1440 --rate 144
#xrandr --output HDMI-0 --same-as DP-2
exec bspwm
