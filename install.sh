#!/bin/bash

set -eufo pipefail

echo ""
echo "This script will setup .dotfiles for you."
read -n 1 -r -s -p $'    Press any key to continue or Ctrl+C to abort...\n\n'


# Install Homebrew
command -v brew >/dev/null 2>&1 || \
  (echo '🍺  Installing Homebrew' && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")


formulae=(
        autojump
        bat
        curl
        deno
        fzf
        git
        git-delta
        jq
        less
        nano
        nvm
        wget
        yarn
        zplug
)
casks=(
        google-chrome
        iterm2
        visual-studio-code
)


brew update

brew install ${formulae[@]}
brew install --cask ${casks[@]}

brew cleanup


# Install Oh My Zsh
if [ ! -f ~/.oh-my-zsh/oh-my-zsh.sh ]; then
  (echo '💰  Installing oh-my-zsh' && yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")
fi

echo ""
echo "Done."
