[[ -v ZEBUG ]] && zmodload zsh/zprof

export ZSH="$HOME/.oh-my-zsh"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

COMPLETION_WAITING_DOTS="true"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# $PATH
export PATH="$PATH:/Users/sean/.local/bin"
export PATH="$PATH:/Users/prometheus/.local/bin"
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH="$(brew --prefix sqlite)/bin:${PATH}"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Evals
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init zsh)"
eval "$(_SQLITE_UTILS_COMPLETE=zsh_source sqlite-utils)"
eval "$(starship init zsh)"
# todo this makes shell load slow
# eval "$(gh copilot alias -- zsh)"

command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

# utils
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Exports
export LOCAL_IP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk     '{print $2}')
export UV_PYTHON="3.11"
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
# TODO put this in its own fzf_ui() fn
# export FZF_DEFAULT_OPTS="--style full --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}'"

# Aliases
alias lg="lazygit"
alias dkr="docker"
alias ztime='time zsh -i -c exit'
alias zconf='vim ~/.zshrc'
alias zload='exec zsh'
alias vim='nvim'
alias vconf='nvim ~/.config/nvim/'
alias vvim='/usr/bin/vim'

source $HOMEBREW_PREFIX/opt/chruby/share/chruby/chruby.sh
chruby 3

[[ -v ZEBUG ]] && zprof

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

