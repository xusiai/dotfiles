### COMMAND LINE TOOLS
alias mtar='tar -zcvf' # mtar <archive_compress>
alias utar='tar -zxvf' # utar <archive_decompress> <file_list>
alias z='zip -r' # z <archive_compress> <file_list>
alias uz='unzip' # uz <archive_decompress> -d <dir>
alias sr='source ~/.zshrc'
alias ..='cd ..'
alias mkdir='mkdir -p'
alias fm='xplr'
alias ls='exa --color=auto --icons'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias cat='bat --color always --plain'
alias grep='grep --color=auto'
alias v='hx'
alias mv='mv -v'
alias cp='cp -vR'
alias rm='rm -vr'
alias clean='find . -xtype l -delete && find -empty -type d -delete'
alias clip='xclip -sel clip < '
alias m3u='find -type f -iname "*.mp3" -or -iname "*.flac" -or -iname "*.m4a" > playlist.m3u"'

alias xclr='for i in *.{png,jpg,jpeg} ; do clrx -i "$i" -o "$i" ; done'

alias lsblk='lsblk -o NAME,FSTYPE,LABEL,MOUNTPOINT,SIZE,MODEL'
alias space='du -cha --max-depth=1 / | grep -E "M|G"'
alias r='$(fc -ln -1)'
alias rs='sudo $(fc -ln -1)'
alias x='exit'
alias c='clear'

### SPECIFIC TO VOID LINUX
alias xi='sudo xbps-install'
alias xr='sudo xbps-remove -Ro'
alias xu='sudo xbps-install -Su'
alias xq='xbps-query'
alias xs='xbps-query -Rs'
alias xsi='cd $HOME/GIT/VP && ./xbps-src pkg'
alias xin='sudo xbps-install --repository $HOME/GIT/VP/hostdir/binpkgs'
alias xnf='sudo xbps-install --repository $HOME/GIT/VP/hostdir/binpkgs/nonfree'
alias xl='xbps-query -l | awk '{ print $2 }' | xargs -n1 xbps-uhelper getpkgname'
alias po='loginctl poweroff'
alias rb='loginctl reboot'

# SPECIFIC TO ME - RELIES ON THIRD PARTY TOOLS OR A SPECIFIC FILE STRUCTURE. 
alias mb='ssh miu@192.168.1.245' 
alias wtr='curl wttr.in/orebro' # Shows weather in the terminal. Replace orebro with your location.
alias mdl='megadl --path /nfs/D1/TM/completed/'
alias ydl='yt-dlp -o /mnt/D1/TM/completed/%(title)s-%(id)s.%(ext)s'
alias wwc='wtwitch c' # Wonderful twitch client which doesn't require an account. Pipes the stream into mpv. See https://github.com/krathalan/wtwitch for more information. 
alias ww='wtwitch w'
alias rname='mnamer --no-overwrite --no-guess --batch --recurse' # Media file renamer in the terminal. Similar to filebot. See https://github.com/jkwill87/mnamer for more information.
alias rnamet='mnamer --no-overwrite --no-guess --batch --recurse --test'
alias rnametv='mnamer --no-overwrite --no-guess --batch --recurse --id-tvdb'
alias rnametvt='mnamer --no-overwrite --no-guess --batch --recurse --test --id-tvdb'
alias dwmr='cd ~/.config/dwm/dwm/ && sudo rm config.h && sudo make install' #
alias d1='cd /nfs/D1'
alias d2='cd /nfs/D2'
alias d3='cd /nfs/D3'
alias d4='cd /nfs/D4'
alias d5='cd /nfs/D5'
alias d6='cd /nfs/D6'
alias tr='cd /nfs/D1/TM/completed'
alias dl='cd ~/XDG/Downloads'
alias dt='cd ~/GIT/DT/'
alias dt='cd ~/GIT/VP/'
alias dt='cd ~/GIT/VL/'
alias cfg='cd ~/.config/'

### GIT
alias commit='git add . && git commit -m'
alias push='git push'
alias clone='git clone'
alias undo='git reset --soft HEAD~1'
alias remote='git remote set-url origin'
alias status='git status'

# MISC
alias code='code-oss'

# vim:ft=zsh
