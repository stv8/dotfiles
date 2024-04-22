[[ -v ZEBUG ]] && zmodload zsh/zprof

export ZSH="$HOME/.oh-my-zsh"

zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 7

COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# $PATH
export PATH="$PATH:/Users/sean/.local/bin"
export PATH="$PATH:/Users/prometheus/.local/bin"
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# evals
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(register-python-argcomplete pipx)"
eval "$(zoxide init zsh)"
command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

# todo this doesn't work on personal
eval "$(gh copilot alias -- zsh)"

# pyenv init
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv &> /dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
command -v 'pyenv virtualenvwrapper_lazy' &> /dev/null && pyenv virtualenvwrapper_lazy


# utils
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# ENV utils
export LOCAL_IP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk     '{print $2}')

# Aliases
alias lg="lazygit"
alias dkr="docker"
# https://github.com/pyenv/pyenv#homebrew-in-macos
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
alias ztime='time zsh -i -c exit'
alias zconf='vim ~/.zshrc'

eval "$(starship init zsh)"

[[ -v ZEBUG ]] && zprof
