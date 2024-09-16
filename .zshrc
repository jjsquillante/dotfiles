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


export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
zplug "plugins/git",   from:oh-my-zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug load

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install


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
alias py="python3"
alias kubectl="minikube kubectl --"

