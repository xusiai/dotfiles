# TOOLBOX
alias sudo='doas'
alias mtar='tar -zcvf' # mtar <archive_compress>
alias utar='tar -zxvf' # utar <archive_decompress> <file_list>
alias z='zip -r' # z <archive_compress> <file_list>
alias uz='unzip' # uz <archive_decompress> -d <dir>
alias sr='source ~/.zshrc'
alias lsl='exa --long --tree'
alias ls='exa'
alias grep='grep --color=auto'
alias mv='mv -v'
alias cp='cp -r'
alias rm='rm -r'
alias lsblkinfo="lsblk -o NAME,FSTYPE,LABEL,MOUNTPOINT,SIZE,MODEL"
alias diskspace='du -cha --max-depth=1 / | grep -E "M|G"'
alias m3u='find -type f -iname "*.mp3" -or -iname "*.flac" -or -iname "*.m4a" > playlist.m3u"'
alias s="sudo"
alias dwmr="cd ~/.config/dwm/dwm/ && sudo rm config.h && sudo make install"
alias sudo='doas'
alias srv='ssh miu@192.168.1.245'
alias clean='find . -xtype l -delete && find -empty -type d -delete'

# NAVIGATION
alias ..="cd .."
alias b="../"
alias dl="cd ~/DL"
alias dt="cd ~/DT/"
alias cfg="cd ~/.config/"
alias d1="cd /nfs/D1"
alias d2="cd /nfs/D2"
alias d3="cd /nfs/D3"
alias d4="cd /nfs/D4"
alias d5="cd /nfs/D5"
alias d6="cd /nfs/D6"
alias tr="cd /nfs/D1/TM/completed"
alias vp="cd ~/VP" 
alias x="exit"
alias c="clear"


# NVIM
alias nvdwm="nvim $HOME/.config/dwm/dwm/config.def.h"
alias nvzsh="nvim $HOME/.zshrc"
alias nvzsha="nvim $HOME/.zshrc.d/alias.zsh"

# GIT
alias gc="git clone"
alias gp="git push"
alias ga="git add ."
alias gm="git commit -m"
alias gcm='git commit -m "$(date)"'
alias gu="git reset --soft HEAD~1"
alias gsetup="git remote set-url origin"
alias gge="git config --global user.email"
alias ggn="git config --global user.name"
alias bspd="git clone https://github.com/Miusaky/bspdots.git"
alias gs="git status"
alias gd="git diff HEAD --name-only"

# APPS
alias mdl="megadl --path /mnt/D1/TM/completed/"
alias ydl="yt-dlp -o /mnt/D1/TM/completed/%(title)s-%(id)s.%(ext)s"
alias wwc="wtwitch c"
alias ww="wtwitch w"
alias mb="kitty +kitten ssh root@192.168.1.253"
alias img="kitty +kitten icat" 
alias rname="mnamer --no-overwrite --no-guess --batch --recurse"
alias rnamet="mnamer --no-overwrite --no-guess --batch --recurse --test"
alias rnametv="mnamer --no-overwrite --no-guess --batch --recurse --id-tvdb"
alias rnametvt="mnamer --no-overwrite --no-guess --batch --recurse --test --id-tvdb"

alias v='nvim'
alias wtr="curl wttr.in/"
alias clr="$HOME/.local/bin/clr >/dev/null 2>&1 && kill -USR1 $(pidof kitty)"

# VOID 
alias xi="sudo xbps-install"
alias xr="sudo xbps-remove -Ro"
alias xu="sudo xbps-install -Su"
alias xq="xbps-query"
alias xs="xbps-query -Rs"
alias xss="ls ~/VP/srcpkgs | fzf"
alias xsi="~/VP/./xbps-src -E pkg"
alias xin="sudo xbps-install --repository ~/VP/hostdir/binpkgs"
alias xuu="cd ~/VP/ && ./xbps-src bootstrap-update"
alias po="loginctl poweroff"
alias rb="loginctl reboot"
alias xl="xbps-query -m"

# VM
alias vmnet="sudo virsh net-start default"

