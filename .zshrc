# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""
plugins=()

source $ZSH/oh-my-zsh.sh
export DENO_INSTALL="/Users/jamessquillante/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 13

eval "$(/opt/homebrew/bin/brew shellenv)"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# load in zplug
[ -f ~/.zplug.sh ] && source ~/.zplug.sh

# kill processes

function kp(){
  if [ -z "$1" ]
  then
	kill -9 $(lsof -t -i tcp:"$1")
  else
	echo "No port given"
	return -1
  fi
}


# User configuration
# ==================
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias rzsh="source ~/.zshrc" # refresh zshrc
alias drmi="docker rmi $(docker images -a -q)" # docker rm images
alias drmc="docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)" # docker remove containers
alias kubectl="minikube kubectl --"

alias py="python3"
alias python="python3"
alias pip="python3 -m pip"
alias venv="source .venv/bin/activate"

alias rzsh="source ~/.zshrc"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# zsh options: http://zsh.sourceforge.net/Doc/Release/Options.html
setopt APPEND_HISTORY # adds history
setopt HIST_IGNORE_ALL_DUPS # If a new command line being added to the history list duplicates an older one, the older command is removed from the list
setopt HIST_IGNORE_SPACE # No history when starting command with space
setopt HIST_SAVE_NO_DUPS # When writing out the history file, older commands that duplicate newer ones are omitted

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# key bindings
bindkey '[C' forward-word   # alt+left
bindkey '[D' backward-word  # alt+right