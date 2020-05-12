#!/bin/bash
set -e
MESSAGES=""

function installGit() {
    which git > /dev/null && return
    sudo apt-get install -y git
    
    grep parse_git_branch ~/.bashrc > /dev/null 2>&1 || {
        cat >> ~/.bashrc <<-GIT_PS1_BASH_RC
            function parse_git_branch {
                git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
            }
        
            export PS1='\u@\h \[\033[32m\]\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ '
GIT_PS1_BASH_RC
    }

    MESSAGES="${MESSAGES}\nCreate an ssh cert for github"
}

function installBuildEssential() {
    which make > /dev/null || sudo apt-get install -y build-essential
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
    nvm ls 10 | grep 10 > /dev/null || nvm install 10 || echo -e "\e[1;91mNo NVM!!!\e[0m"
}

function installHeroku() {
    which heroku > /dev/null || sudo snap install heroku --classic
}

function installTmux() {
    which tmux > /dev/null || sudo apt-get install -y tmux
}

function installTree() {
    which tree > /dev/null || sudo apt-get install -y tree
}

function installJq() {
    which jq > /dev/null || sudo apt-get install -y jq
}

function installCurl() {
    which curl > /dev/null || sudo apt-get install -y curl
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
    [ -f ~/.bash_aliases ] && return
    cat > ~/.bash_aliases <<-BASH_ALIASES
alias gs='git status'
alias gd='git diff'
alias sgrep='grep -r --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=public --exclude-dir=lib --exclude-dir=dist'
alias int='npm run $(jq --raw-output ".scripts | keys[]" package.json | grep int | grep -v lint)'
BASH_ALIASES
    MESSAGES="${MESSAGES}\nsource ~/.bashrc or relogin for aliases changes to take effect"
}

function installTypeScript() {
    which tsc > /dev/null && return
    npm install -g typescript
}

function installAngularCLI() {
    npm ls -g @angular/cli > /dev/null 2>&1 && return
    npm install -g @angular/cli
}

function setupKeyboardMapping() {
    grep setxkbmap ~/.bashrc > /dev/null 2>&1 || {
        echo 'setxkbmap -option grp:switch,grp:alt_shift_toggle,grp_led:scroll,caps:escape gb,il' >> ~/.bashrc
        MESSAGES="${MESSAGES}\nsource ~/.bashrc or relogin for keyboard mapping changes to take effect"
    }
}

function setupSSHKeys() {
  if [ ! -f ~/.ssh/id_rsa ]; then
    read -ep "Please enter email for ssh keys: " sshemail
    echo
    ssh-keygen -t rsa -b 4096 -C "${sshemail}"
    MESSAGES="${MESSAGES}\nAdd new ssh keys to github and gitlab.\e[0m"
  fi
}

function installObsStudio() {
    which obs > /dev/null && return
    apt-get install -y ffmpeg
	add-apt-repository ppa:obsproject/obs-studio
	apt update
	apt install -y obs-studio
}

function installPostgres() {
    which psql > /dev/null && return
    sudo apt-get install -y postgresql postgresql-contrib
    sudo -u postgres createuser -s $(whoami)
    sudo -u postgres createdb $(whoami)
}

function installOpenShot() {
    which openshot-qt > /dev/null && return
	add-apt-repository -y ppa:openshot.developers/ppa
	apt-get update
	apt-get install -y openshot-qt
}

installGit
installBuildEssential
installNvm
installTmux
installTree
installCurl
installJq
installVimAndPlugged
#installHeroku
setupProjectsDir
setupDotFiles
setupAliases
setupKeyboardMapping
#installJavaAndMaven
#installDocker
#installTypeScript
#installAngularCLI
setupSSHKeys
#installObsStudio
#installPostgres
#installOpenShot
showFinishingMessages
