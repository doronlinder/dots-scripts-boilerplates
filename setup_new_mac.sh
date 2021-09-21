#!/bin/zsh
set -e
MESSAGES=""

function installOhMyZsh() {
    # Don't install if already installed
    [ -d ~/.oh-my-zsh ] && return

    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function fixHomebrewForZsh() {
    grep homebrew ~/.zshrc > /dev/null 2>&1 || {
	    sed -i '' -e '/# export PATH=/ a\
export PATH=~/.homebrew/bin:$PATH:/usr/local/jamf/bin' ~/.zshrc
        source ~/.zshrc
    }
}

function installNvm() {
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-nvm ]; then
        git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
    fi

    grep zsh-nvm ~/.zshrc > /dev/null 2>&1 || {
	sed -e 's/^plugins=(\(.*\))$/plugins=(\1 zsh-nvm)/' -i ''  ~/.zshrc
    }

    source ~/.zshrc
    source ~/.oh-my-zsh/oh-my-zsh.sh
    nvm ls 14 | grep 14 > /dev/null || nvm install 14 || echo -e "\e[1;91mNo NVM!!!\e[0m"
}

function installTmux() {
    which tmux > /dev/null || brew install tmux

    # Check out /Users/n17015/.homebrew/opt/tmux/share/tmux if there are problems
}

function installTree() {
    which tree > /dev/null || brew install tree
}

function installJq() {
    which jq > /dev/null || brew install jq
}

function installYarn() {
    which yarn > /dev/null || npm install -g yarn
}

function installVimPrettier() {
    mkdir -p ~/.vim/pack/plugins/start
    [ -d ~/.vim/pack/plugins/start/vim-prettier ] || git clone https://github.com/prettier/vim-prettier ~/.vim/pack/plugins/start/vim-prettier
}

function setupProjectsDir() {
    mkdir -p ~/projects
}

function setupDotFiles() {
    [ -d ~/projects/dots-scripts-boilerplates ] && return
    cd ~/projects
    git clone https://github.com/doronlinder/dots-scripts-boilerplates.git
    cd dots-scripts-boilerplates
    cp .vimrc.mac ~/.vimrc
    cp .tmux.conf ~/.
}


function showFinishingMessages() {
    echo -e "\n\e[1;91m${MESSAGES}\e[0m"
}

function setupAliases() {
    grep 'alias gs=' ~/.zshrc > /dev/null 2>&1 || echo 'alias gs="git status"' >> ~/.zshrc
    grep 'alias sgrep=' ~/.zshrc > /dev/null 2>&1 || echo 'alias sgrep="grep -r --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=public --exclude-dir=lib --exclude-dir=dist"' >> ~/.zshrc
    source ~/.zshrc
    MESSAGES="${MESSAGES}\nSource ~/.zshrc or relogin for aliases to take effect.\e[0m"
}

function installTypeScript() {
    which tsc > /dev/null && return
    npm install -g typescript
}

function setupSSHKeys() {
  if [ ! -f ~/.ssh/id_rsa ]; then
    vared -p "Please enter email for ssh keys: " -c sshemail
    echo
    ssh-keygen -t rsa -b 4096 -C "${sshemail}"
    MESSAGES="${MESSAGES}\nAdd new ssh keys to github and gitlab.\e[0m"
  fi
}

function installPostgres() {
    which psql > /dev/null && return
    sudo apt-get install -y postgresql postgresql-contrib
    sudo -u postgres createuser -s $(whoami)
    sudo -u postgres createdb $(whoami)
}

installOhMyZsh
installNvm
fixHomebrewForZsh
installTmux
installTree
installJq
installVimPrettier
setupProjectsDir
setupDotFiles
setupAliases
setupSSHKeys

#installTypeScript
#installYarn
#installPostgres

showFinishingMessages
