export PATH="/opt/LEAGUEOFLEGENDS:$PATH"
export PATH="$HOME/.local/bin:$PATH"

if [ -z "$DISPLAY" ] && [ "$(fgconsole)" -eq 1 ]; then
   sx dbus-launch --exit-with-session sh ~/.config/dwm/scripts/run.sh 
fi
