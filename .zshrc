#! /bin/zsh
SHELL=$(which zsh || echo '/bin/zsh')

setopt autocd              # change directory just by typing its name
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt
setopt MENU_COMPLETE       # Automatically highlight first element of completion menu
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.

# env
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin/:$PATH"
export PATH="$HOME/.local/bin/wtwitch/:$PATH"
export PATH="/opt/wine-lol/bin/:$PATH"
export PATH="$HOME/.nvm/node_modules/.bin/:$PATH"
export AWESOME_IGNORE_LGI=1

# enable completion features
autoload -Uz compinit
compinit -i

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.config/zsh/.zcompcache"

# Define completers
zstyle ':completion:*' completer _extensions _complete _approximate

zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'

zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Only display some tags for the command cd
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories

# History configurations
HISTFILE="$HOME/.cache/.zsh_history"
HISTSIZE=10000
SAVEHIST=20000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# source plugins
source $HOME/antigen.zsh
antigen use oh-my-zsh
antigen bundle git
antigen bundle fzf
antigen bundle pip
antigen bundle colorize
antigen bundle command-not-found
antigen bundle gitfast
antigen bundle ufw
antigen bundle zsh-interactive-cd
antigen bundle copypath
antigen bundle cp
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle laggardkernel/zsh-thefuck
antigen bundle chrissicool/zsh-256color
antigen bundle ael-code/zsh-colored-man-pages
antigen theme spaceship-prompt/spaceship-prompt
antigen apply

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#484E5B,underline"

# tty
if [ "$TERM" = "linux" ] ; then
    echo -en "\e]P0232323"
fi

# custom function
toppy() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n 21
}

cd() {
	builtin cd "$@" && command ls --group-directories-first --color=auto -F
}

mcd () {
    mkdir -p $1
    cd $1
}

# alias
alias grub-update='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias mtar='tar -zcvf' # mtar <archive_compress>
alias utar='tar -zxvf' # utar <archive_decompress> <file_list>
alias z='zip -r' # z <archive_compress> <file_list>
alias uz='unzip' # uz <archive_decompress> -d <dir>
alias sr='source ~/.zshrc'
alias ..="cd .."
alias b="../"
alias x="exit"
alias c="clear"

alias dl="cd ~/DL"
alias dt="cd ~/DT"
alias cfg="cd ~/.config/"
alias d1="cd /mnt/D1"
alias d2="cd /mnt/D2"
alias d3="cd /mnt/D3"
alias tm="cd /mnt/D1/TM/completed"

alias mkdir="mkdir -p"
alias fm='xplr'

alias l="ls -l"
alias la="ls -a"
alias lla="ls -la"
alias lt="ls --tree"
alias grep='grep --color=auto'
alias v='nvim'
alias mv='mv -v'
alias cp='cp -vr'
alias rm='rm -vr'
alias gc="git clone"
alias gp="git push"
alias ga="git add ."
alias gm="git commit -m"
alias gcm='git commit -m "$(date)"'
alias gsetup="git remote set-url origin"
alias gge="git config --global user.email"
alias ggn="git config --global user.name"
alias miud="git clone https://github.com/Miusaky/DT.git"

alias wtr="curl wttr.in/"
alias lsblkinfo="lsblk -o NAME,FSTYPE,LABEL,MOUNTPOINT,SIZE,MODEL"
alias diskspace='du -cha --max-depth=1 / | grep -E "M|G"'
alias m3u='find -type f -iname "*.mp3" -or -iname "*.flac" -or -iname "*.m4a" > playlist.m3u"'
alias mdl="megadl --path /mnt/D1/TM/completed/"
alias ydl="yt-dlp -o /mnt/D1/TM/completed/%(title)s-%(id)s.%(ext)s"
alias wwc="wtwitch c"
alias ww="wtwitch w"
alias tl="tb -l"
alias ta="tb -t"
alias ts="tb -s"
alias tc="tb -c"
alias td="tb -d"
alias tbc="tb --clear"
alias tba="tb --archive"

alias mirror-update='sudo reflector --verbose -c Sweden -c Finland -c Norway --sort rate --save /etc/pacman.d/mirrorlist'
alias pacs="pacman -Slq | fzf -m --preview 'cat <(pacman -Si {1}) <(pacman -Fl {1} | awk \"{print \$2}\")' | xargs -ro sudo pacman -S"
alias pars="paru -Slq | fzf -m --preview 'cat <(paru -Si {1}) <(paru -Fl {1} | awk \"{print \$2}\")' | xargs -ro  paru -S"
alias pacr="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"
alias p="pacman -Q | fzf"

alias xi="sudo xbps-install"
alias xr="sudo xbps-remove -Ro"
alias xu="sudo xbps-install -Su"
alias xq="xbps-query"
alias xs="xbps-query -Rs"
alias xss="ls ~/VP/srcpkgs | fzf"
alias xsi="~/VP/./xbps-src -E pkg"
alias xin="sudo xbps-install --repository hostdir/binpkgs"
alias xuu="cd ~/VP/ && ./xbps-src bootstrap-update"
alias po="loginctl poweroff"
alias rb="loginctl reboot"
alias xl="xbps-query -m"

# prompt
SPACESHIP_USER_SHOW="always"
SPACESHIP_PROMPT_SEPARATE_LINE="false"
SPACESHIP_CHAR_SYMBOL=" "

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
