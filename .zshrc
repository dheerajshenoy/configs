# CUSTOM PROMPT
PROMPT="%~ > "

# TAB COMPLETION FOR ARGUMENTS
autoload -U compinit
compinit


alias cat='bat'
alias ..='cd ..'
alias vim='nvim'
alias v='nvim'
alias ht='htop'
alias nf='neofetch'
alias ka='killall'
alias ns='notify-send'
alias zrc='vim ~/.zshrc'
alias vrc='vim ~/.config/nvim/init.vim'
alias z='zathura'
alias py='python'

# DIR ALIAS
alias pydir='cd ~/dheeraj/python/'
alias cppdir='cd ~/dheeraj/cpp/'
alias cdir='cd ~/dheeraj/c/'
alias arddir='cd ~/dheeraj/arduino/'
alias ddir='cd ~/.config/dwm'
alias awdir='cd ~/.config/awesome'

# DWM ALIAS
alias dwmres='rm -rf config.h && sudo make clean install'

# GITHUB ALIAS
alias gc='git clone'
alias gb='git branch'
alias gco='git checkout'
alias gco='git commit -m'


# KITTY TERMINAL SPECIFIC ALIAS
alias img='kitty +kitten icat'

alias xres='xmonad --recompile && xmonad --restart'

#(cat ~/.cache/wal/sequences &)

# To add support for TTYs this line can be optionally added.
#source ~/.cache/wal/colors-tty.sh

E='vim'

# ENVIRONMENT VARIABLES
CALCURSE_PAGER=$E
PAGER=$E
EDITOR=$E
VISUAL=$E
CALCURSE_EDITOR=$E

# ZSH SYNTAX HIGHLIGHTING
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
