#!/bin/bash
set -e

function installGit() {
    which git > /dev/null && return
    sudo apt-get install -y git
    
    grep parse_git_branch ~/.bashrc > /dev/null 2>&1 || {
        cat >> ~/.bashrc <<-GIT_PS1_BASH_RC
            function parse_git_branch {
                git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
            }
        
            export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
GIT_PS1_BASH_RC
    }

    MESSAGES="${MESSAGES}\nCreate an ssh cert for github"
}

function installNvm() {

    if [ ! -d ~/.nvm ]; then
        git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`
    fi

    grep nvm ~/.bashrc > /dev/null 2>&1 || {
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm' >> ~/.bashrc
        MESSAGES="${MESSAGES}\nsource ~/.bashrc or relogin for nvm changes to take effect"
    }

    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm ls 6 | grep 6 > /dev/null || nvm install 6 || echo -e "\e[1;91mNo NVM!!!\e[0m"
}

function installTmux() {
    which tmux > /dev/null || sudo apt-get install -y tmux
}

function installVimAndPlugged() {

    which vim > /dev/null || sudo apt-get install -y vim
    if [ ! -f ~/.vim/autoload/plug.vim ]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        MESSAGES="${MESSAGES}\nRun PlugInstall in vim.\e[0m"
    fi
}

function setupProjectsDir() {
    mkdir -p ~/projects
}

function setupDotFiles() {
    [ -d ~/projects/dots-scripts-boilerplates ] && return
    cd ~/projects
    git clone https://github.com/doronlinder/dots-scripts-boilerplates.git
    cd dots-scripts-boilerplates
    cp .vimrc ~/.
    cp .tmux.conf ~/.
}

function installJavaAndMaven() {
    which mvn > /dev/null && return
    sudo apt-get install -y maven
    sudo apt-get install -y openjdk-8-jdk-headless
    MESSAGES="${MESSAGES}\nRun mvn once and then copy maven repository settings with scp from other machine's ~/.m2/settings.xml"
}

function installDocker() {
    which docker > /dev/null && return
    sudo apt-get install -y docker.io docker-compose
    sudo usermod -aG docker $USER
    MESSAGES="${MESSAGES}\nIn order for docker to work for anyone but root you need to reboot\e[0m"
}

function showFinishingMessages() {
    which google-chrome > /dev/null || MESSAGES="${MESSAGES}\nInstall Chrome manually"
    echo -e "\n\e[1;91m${MESSAGES}\e[0m"
}

function setupAliases() {
    cat > ~/.bash_aliases <<-BASH_ALIASES
        alias gs='git status'
        alias gd='git diff'
BASH_ALIASES
    MESSAGES="${MESSAGES}\nsource ~/.bashrc or relogin for aliases changes to take effect"
}

installGit
installNvm
installTmux
installVimAndPlugged
setupProjectsDir
setupDotFiles
setupAliases
#installJavaAndMaven
#installDocker
showFinishingMessages
