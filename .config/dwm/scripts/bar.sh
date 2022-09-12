#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/dwm/scripts/bar_themes/SAGA

mpd() {
PS=$(2>/dev/null playerctl status)
NP='No players found'

  if [[ "$PS" == *"$NP"* ]]; then
    printf " "
  else
    printf "^c$blue^$(playerctl metadata --format '{{ uc(artist) }}') "
    printf "^c$pink^$(playerctl metadata --format '{{ uc(title) }}') "

  fi
} 

pkg_updates() {
  updates=$(xbps-install -un | wc -l)

  if [ -z "$updates" ]; then
    printf "^c$green^󰹻 "
  else
    printf "^c$green^󰹻 ^c$white^$updates "
  fi
}

gputemp() {
  printf "^c$orange^^b$black^󰖺 "
  printf "^c$white^$(nvidia-smi --query-gpu=temperature.gpu --format=nounits,csv,noheader | awk '{print ""$1"""°"}')"
}

cputemp() {
  printf "^c$pink^^b$black^󰝨 "
  printf "^c$white^$(sensors | grep "Tctl" | tr -d '+' | tr -d \C | tr -d \Tctl: | tr -d \  | awk -F. '{print ""$1"""°"}')"
}

mem() {
  printf "^c$blue^^b$black^󰆼 "
  printf "^c$white^$(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

clock() {
	printf " ^c$white^^b$black^$(date '+%H:%M')  "
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$(mpd) $updates $(gputemp) $(cputemp) $(mem) $(clock)"
done

############################ UNUSED FUNCTIONS ###############################
#
# disk() {
#    printf "^c$blue^^b$black^󰆼"
#    printf "^c$white^$(df / | awk '{print $5}' | tr -d 'Use%')"
# }
#
# wlan() {
#	  case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
#	  up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
#	  down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
# 	esac
# }
#
# battery() {
#    get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
#   printf "^c$blue^   $get_capacity"
# }
#
# brightness() {
#   printf "^c$red^   "
#   printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
# }
#
# cpu() {
#    cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
#
#    printf "^c$pink^^b$black^󱕍 "
#    printf "^c$white^^b$black^$cpu_val "
# }
#
# gpu() {
#    printf "^c$orange^^b$black^󰖺 "
#    printf "^c$white^$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print ""$1"""%"}')"
# }
