[[ -v ZEBUG ]] && zmodload zsh/zprof

export ZSH="$HOME/.oh-my-zsh"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

COMPLETION_WAITING_DOTS="true"
HOMEBREW_NO_VERIFY_ATTESTATIONS=1

plugins=(git)

if [ -e $ZSH/oh-my-zsh.sh ]; then
  source $ZSH/oh-my-zsh.sh
fi

autoload -Uz compinit
compinit
source <(fzf --zsh)

# Evals
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init zsh)"
eval "$(_SQLITE_UTILS_COMPLETE=zsh_source sqlite-utils)"
eval "$(starship init zsh)"
# todo this makes shell load slow
# eval "$(gh copilot alias -- zsh)"

# $PATH
# note must come after brew shellenv to setup tool specific paths
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
export PATH="$(brew --prefix sqlite)/bin:${PATH}"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
export PATH="$PATH:/opt/homebrew/bin"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

command -v direnv &> /dev/null && eval "$(direnv hook zsh)"
command -v aws &> /dev/null && complete -C '/opt/homebrew/bin/aws_completer' aws

# utils
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Exports
export LOCAL_IP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk     '{print $2}')
export UV_PYTHON="3.11"
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
export BUNDLER_VERSION="4.0.6"
# TODO put this in its own fzf_ui() fn
# export FZF_DEFAULT_OPTS="--style full --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}'"

# Aliases
alias lg="lazygit"
alias lzd="lazydocker"
alias dkr="docker"
alias dcu="docker compose up"
alias dcd="docker compose down"
alias dcr="docker compose down && docker compose up"
alias ztime='time zsh -i -c exit'
alias zconf='vim ~/.zshrc'
alias zload='exec zsh'
alias vim='nvim'
alias vconf='nvim ~/.config/nvim/'
alias vvim='/usr/bin/vim'
alias mx="mise x --"
alias claude="mx claude"
alias uvr="uv run"

source "$HOME/.zsh/git.plugin.zsh"
source "$HOME/.secret.zsh"


if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi


[[ -v ZEBUG ]] && zprof

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}


# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/src/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/src/google-cloud-sdk/path.zsh.inc"; fi
# The next line enables shell command completion for gcloud.
if [ -f "$HOME/src/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/src/google-cloud-sdk/completion.zsh.inc"; fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
eval "$(mise activate zsh)" # after homebrew so mise execs are found first
eval "$(atuin init zsh)"
