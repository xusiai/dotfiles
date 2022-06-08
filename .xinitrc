#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# MERGE DEFAULTS AND KEYMAPS

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# AUTOSTART APPLICATIONS

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

ksuperkey 
#pipewire & 
#pipewire-pulse & 
xfce4-power-manager &
mpd 
kdeconnect-cli &
/usr/libexec/polkit-gnome-authentication-agent-1 &
/usr/libexec/xdg-desktop-portal-gtk &
setxkbmap se 
xsetroot -cursor_name left_ptr 
feh --recursive --randomize --bg-scale $HOME/.local/share/wallpapers 
mpDris2 &
#easyeffects --gapplication-service &
exec dbus-run-session bspwm
