export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin/colorscripts:$PATH"
export PATH="$HOME/.config/rofi/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH"
export PATH="/opt/LEAGUEOFLEGENDS:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export GTK_OVERLAY_SCROLLING=1
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
export FZF_DEFAULT_OPTS='--color=bg+:#0A0D0F,bg:#0F1214,spinner:#FFFFC1,hl:#FFBDCB --color=fg:#FFFCFF,header:#FFBDCB,info:#D2C5E8,pointer:#FFDCAC --color=marker:#FFDCAC,fg+:#F5D0D0,prompt:#D2C5E8,hl+:#FFBDCB'

if [ "$TERM" = "linux" ] ; then
    printf '%b' '\e]P0 #0A0D0F
                 \e]P1 #FFB2AD
                 \e]P2 #B4F8C8
                 \e]P3 #FFFFC1
                 \e]P4 #F5E8FF
                 \e]P5 #FFBDCB
                 \e]P6 #7ed1f6
                 \e]P7 #FFFCFF
                 \e]P8 #191C1E
                 \e]P9 #ffbcb7
                 \e]PA #beffd2
                 \e]PB #ffffcb
                 \e]PC #FAEDFF
                 \e]PD #ffc7d5
                 \e]PE #92e5ff
                 \e]PF #ffffff
                 \ec'
    clear
fi

xrandr --output DP-2 --mode 2560x1440 --rate 144
#xrandr --output HDMI-0 --same-as DP-2

if [ -z "$DISPLAY" ] && [ "$(fgconsole)" -eq 1 ]; then
   sx dbus-launch --exit-with-session sh ~/.config/dwm/scripts/run.sh 
fi
