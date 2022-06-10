#!/usr/bin/env sh

if ! pgrep -x polybar; then
    polybar -c ~/.config/polybar/config.ini base &
else
    pkill -USR1 polybar
fi
