# ~/.bashrc — MacBook 12" 2017 Arch Linux Matrix Theme

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# --- History ---
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend

# --- Shell options ---
shopt -s checkwinsize
shopt -s globstar 2>/dev/null
shopt -s cdspell

# --- Colors ---
# Only override TERM on SSH/X sessions, not on Linux console (tty)
if [ "$TERM" != "linux" ]; then
    export TERM="xterm-256color"
fi

# Matrix green color palette
C_RESET='\[\e[0m\]'
C_GREEN='\[\e[38;5;46m\]'
C_DGREEN='\[\e[38;5;22m\]'
C_LIME='\[\e[38;5;118m\]'
C_DIM='\[\e[38;5;240m\]'
C_WHITE='\[\e[38;5;255m\]'
C_RED='\[\e[38;5;196m\]'
C_BOLD='\[\e[1m\]'

# --- Prompt ---
__prompt_cmd() {
    local exit_code=$?
    local exit_color
    if [ $exit_code -eq 0 ]; then
        exit_color="${C_GREEN}"
    else
        exit_color="${C_RED}"
    fi

    # Git branch (lightweight)
    local git_branch=""
    if command -v git &>/dev/null; then
        git_branch=$(git branch --show-current 2>/dev/null)
        if [ -n "$git_branch" ]; then
            git_branch=" ${C_DGREEN}[${C_LIME}${git_branch}${C_DGREEN}]"
        fi
    fi

    PS1="${C_DGREEN}┌─${C_GREEN}${C_BOLD}\u${C_RESET}${C_DGREEN}@${C_LIME}${C_BOLD}\h${C_RESET} ${C_DIM}\w${git_branch}\n${C_DGREEN}└─${exit_color}▶${C_RESET} "
}
PROMPT_COMMAND=__prompt_cmd

# --- Aliases: Core ---
alias ls='ls --color=auto -F'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias diff='colordiff'
alias df='duf'
alias du='gdu'
alias free='free -m'
alias cat='bat --style=plain --paging=never'
alias less='bat --paging=always'
alias find='fd'
alias rg='rg --color=auto'

# --- Aliases: Tmux ---
alias t='tmux new-session -A -s main'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'

# --- Aliases: System monitoring ---
alias top='btop'
alias mon='btop'
alias nf='fastfetch'
alias sys='inxi -Fxz'
alias temps='cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | awk "{printf \"%.1f°C\\n\", \$1/1000}"'
alias psmem='ps aux --sort=-%mem | head -15'
alias pscpu='ps aux --sort=-%cpu | head -15'

# --- Aliases: File management ---
alias fm='ranger'
alias mc='mc --nosubshell'
alias n='nnn -deH'
alias ncdu='ncdu --color dark'

# --- Aliases: Git ---
alias g='git'
alias gs='git status -sb'
alias gl='git log --oneline -20'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gt='tig'
alias gb='tig blame'

# --- Aliases: Network ---
alias myip='curl -s ifconfig.me && echo'
alias ports='sudo ss -tulnp'
alias ping='ping -c 5'
alias trace='mtr --report'
alias speed='speedtest-cli --simple'
alias net='sudo iftop -i wlan0'
alias netstat='sudo nethogs'
alias wifi='nmtui'

# --- Aliases: Media ---
alias music='cmus'
alias vis='cava'
alias play='mpv --no-video'

# --- Aliases: Fun / Eye candy ---
alias matrix='cmatrix -ab -u 4 -C green'
alias clock='tty-clock -scC 2'
alias bonsai='cbonsai -li'
alias pipes='pipes.sh 2>/dev/null || echo "not installed"'

# --- Aliases: Productivity ---
alias cal='calcurse'
alias task='task'
alias rss='newsboat'
alias irc='irssi'
alias mail='neomutt'
alias web='w3m'
alias edit='nvim'
alias e='micro'
alias calc='bc -lq'
alias weather='curl -s wttr.in/?format=3'
alias cheat='curl -s cheat.sh/'

# --- Aliases: File viewers ---
alias img='chafa --size=80x40'
alias imgfull='chafa'
alias exif='exiv2'
alias pdf='pdftotext -layout'
alias info='mediainfo'

# --- Aliases: Archives ---
alias extract='atool -x'
alias compress='atool -a'

# --- Aliases: MacBook brightness/volume (console) ---
alias bri+='sudo brightnessctl s +10%'
alias bri-='sudo brightnessctl s 10%-'
alias kbd+='sudo brightnessctl -d spi::kbd_backlight s +25'
alias kbd-='sudo brightnessctl -d spi::kbd_backlight s 25-'
alias vol+='amixer -q set Master 5%+ 2>/dev/null || amixer -q set PCM 5%+'
alias vol-='amixer -q set Master 5%- 2>/dev/null || amixer -q set PCM 5%-'
alias mute='amixer -q set Master toggle 2>/dev/null || amixer -q set PCM toggle'

# --- LS_COLORS (matrix-green accented) ---
export LS_COLORS='di=1;32:ln=36:so=35:pi=33:ex=1;92:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;42:*.tar=31:*.gz=31:*.zip=31:*.deb=31:*.rpm=31:*.jpg=35:*.png=35:*.mp3=36:*.mp4=36'

# --- PATH ---
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export TERMINFO=/usr/share/terminfo

# --- Editor ---
export EDITOR=micro
export VISUAL=micro

# --- fzf integration ---
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS='--color=fg:#00ff41,bg:#0a0a0a,hl:#00cc33,fg+:#00ff41,bg+:#0d2b0d,hl+:#00ff41,info:#006600,prompt:#00ff41,pointer:#00ff41,marker:#00ff41,spinner:#006600,header:#006600 --layout=reverse --border --height=40%'
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
    # Load fzf keybindings (Arch path)
    [ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
    [ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash
fi

# --- nnn config ---
export NNN_COLORS='2346'
export NNN_FCOLORS='0b0b04060006060009060b06'
export NNN_PLUG='f:fzcd;p:preview-tui;d:diffs'
export NNN_FIFO='/tmp/nnn.fifo'

# --- Less (pager) ---
export LESS='-R -i -M'
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;36m'

# --- Auto-start tmux on login (console + SSH, but not inside tmux or over scp) ---
if command -v tmux &>/dev/null && [ -z "$TMUX" ] && [[ $- == *i* ]]; then
    exec tmux new-session -A -s main
fi

# --- Show MOTD once per login (inside tmux only) ---
if [ -n "$TMUX" ] && [ -z "$_TUI_MOTD_DONE" ]; then
    export _TUI_MOTD_DONE=1
    [ -x ~/bin/motd ] && ~/bin/motd
fi
