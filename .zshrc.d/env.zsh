# PATH

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.spicetify:$PATH"
export PATH="/opt/LEAGUEOFLEGENDS:$PATH"


# ENV
export ZSHRCD="$HOME/.zshrc.d"
export STARSHIP_CONFIG="$HOME/.zshrc.d/starship"

# APPS
export EDITOR="nvim"
export TERMINAL="st"
export BROWSER="firefox"

# GTK
export GTK_OVERLAY_SCROLLING=1

# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$XDG_DATA_HOME/flatpak/exports/share"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_DESKTOP_DIR="$HOME/DL/MISC"
export XDG_DOWNLOAD_DIR="$HOME/DL"
export XDG_TEMPLATES_DIR="$HOME/DL/MISC"
export XDG_PUBLICSHARE_DIR="$HOME/DL/MISC"
export XDG_DOCUMENTS_DIR="$HOME/DL/MISC"
export XDG_MUSIC_DIR="/mnt/NFS/D3/MUSIC/M3U"
export XDG_PICTURES_DIR="$HOME/DL/MISC"
export XDG_VIDEOS_DIR="$HOME/DL/MISC"

# MISC
export SUDO_PROMPT="passwd: "

## Comment this to use normal manpager
export MANPAGER='nvim +Man! +"set nocul" +"set noshowcmd" +"set noruler" +"set noshowmode" +"set laststatus=0" +"set showtabline=0" +"set nonumber"'

if [ $(echo $MANPAGER | awk '{print $1}') = nvim ]; then
  export LESS="--RAW-CONTROL-CHARS"
  export MANPAGER="less -s -M +Gg"

  export LESS_TERMCAP_mb=$'\e[1;32m'
  export LESS_TERMCAP_md=$'\e[1;32m'
  export LESS_TERMCAP_me=$'\e[0m'
  export LESS_TERMCAP_se=$'\e[0m'
  export LESS_TERMCAP_so=$'\e[01;33m'
  export LESS_TERMCAP_ue=$'\e[0m'
  export LESS_TERMCAP_us=$'\e[1;4;31m'
fi


