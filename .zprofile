export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin/colorscripts:$PATH"
export PATH="$HOME/.config/rofi/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH"
export PATH="/opt/LEAGUEOFLEGENDS:$PATH"
export PATH="$HOME/.spicetify/:$PATH"
export ZSHRCD="$HOME/.zshrc.d"
export STARSHIP_CONFIG=$HOME/.zshrc.d/starship
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export GTK_OVERLAY_SCROLLING=1

xrandr --output DP-2 --mode 2560x1440 --rate 144
#xrandr --output HDMI-0 --same-as DP-2

if [ -z "$DISPLAY" ] && [ "$(fgconsole)" -eq 1 ]; then
   sx dbus-launch --exit-with-session sh ~/.config/dwm/scripts/run.sh 
fi
