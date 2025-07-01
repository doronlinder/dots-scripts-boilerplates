#!/bin/bash
set -e
MESSAGES=""

function installGit() {
    if ! which git > /dev/null; then
      sudo apt-get install -y git
      MESSAGES="${MESSAGES}\nCreate an ssh cert for github"
    fi

    if ! grep parse_git_branch ~/.bashrc > /dev/null 2>&1; then
        cat >> ~/.bashrc <<-GIT_PS1_BASH_RC
            function parse_git_branch {
                git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
            }

            export PS1='\[\033[34m\]\h\[\033[33m\] \[\033[32m\]\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ '
GIT_PS1_BASH_RC
      MESSAGES="${MESSAGES}\nSource ~/.bashrc to have git supported PS1"
    fi
}

function installBuildEssential() {
    which make > /dev/null || sudo apt-get install -y build-essential
}

function installNetTools() {
    which netstat > /dev/null || sudo apt-get install -y net-tools
}

function installVolta() {
  if ! which volta > /dev/null; then
    curl https://get.volta.sh | bash
    source ~/.bashrc
    source ~/.profile
    ~/.volta/bin/volta install node
  fi
}

function uninstallVolta() {
    rm -rf ~/.volta
    sed -i '/volta/I d' ~/.bashrc
    sed -i '/volta/I d' ~/.profile
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

    if ! grep 'export EDITOR=' ~/.bashrc > /dev/null 2>&1; then
        echo 'export EDITOR=vim' >> ~/.bashrc
        MESSAGES="${MESSAGES}\nSource ~/.bashrc to have vim as the defaul EDITOR"
    fi

    which rg > /dev/null || sudo apt-get install -y ripgrep

    # To have syntax highlighting in :GitFiles
    if ! which batcat > /dev/null; then
        sudo apt-get install bat
        # mkdir -p ~/.local/bin
        # ln -s /usr/bin/batcat ~/.local/bin/bat
    fi
}

function installNeoVim() {

    # Install nvim
    if ! which nvim > /dev/null 2>&1; then
      if [ ! -d ~/nvim-linux-x86_64 ]; then
        cd ~
        rm -f ~/nvim-linux-x86_64.tar.gz
        # Last updated script for this version
        wget https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
        # But we can try taking the latest
        # wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        tar -xvzf ~/nvim-linux-x86_64.tar.gz
        rm -f ~/nvim-linux-x86_64.tar.gz
      fi
      sudo ln -s ~/nvim-linux-x86_64/bin/nvim /usr/bin/nvim
    fi

    # Set as default EDITOR
    if ! grep 'export EDITOR=n' ~/.bashrc > /dev/null 2>&1; then
        echo 'export EDITOR=nvim' >> ~/.bashrc
        MESSAGES="${MESSAGES}\nSource ~/.bashrc to have NEO vim as the defaul EDITOR"
    fi

    if [ ! -z "$RENEW_NVIM_SETUP" ]; then
        rm -rf ~/.config/nvim
        rm -rf ~/.local/share/nvim
    fi

    # Use nvim kickstart as a baseline configuration
    if [ ! -d ~/.config/nvim ]; then

      which rg > /dev/null || sudo apt-get install -y ripgrep
      which unzip > /dev/null || sudo apt-get install -y unzip

      git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
      # latest hash I updated the script to
      cd "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
      git checkout 3338d3920620861f8313a2745fd5d2be39f39534
      cd -
      nvim --headless "+Lazy! sync" +qa

      # Add support for Ctrl-P as git files
      sed -i -e '/<leader><leader>/i\ \ \ \ \ \ vim.keymap.set('\''n'\'', '\''<C-p>'\'', builtin.git_files, { desc = '\''Git files (Ctrl-P)'\'' })' ~/.config/nvim/init.lua

      # Change grd (goto definition) to gd
      sed -i -e '/lsp_definitions/s/grd/gd/' ~/.config/nvim/init.lua

      # Support typescript language server out of the box
      sed -i -e '/-- ts_ls = {}/s/-- //' ~/.config/nvim/init.lua

      # Add my plugins at the end
      sed -i -e '/^}, {$/i PLUGINS_PLACEHOLDER' ~/.config/nvim/init.lua
      sed -i -e '/PLUGINS_PLACEHOLDER/ r '<( { cat <<MY_PLUGINS
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
    config = function()
      -- vim.keymap.set('n', '<leader>gd', ':TSToolsGoToSourceDefinition', { desc = '[G]oto [D]efinition' })
    end,
  },
  {
    'navarasu/onedark.nvim',
    priority = 999, -- make sure to load this before all the other start plugins
    config = function()
      require('onedark').setup {
        style = 'darker',
      }
      -- Enable theme
      require('onedark').load()
    end,
  },
MY_PLUGINS
    } | tr '"' "'" ) ~/.config/nvim/init.lua

    sed -i -e '/PLUGINS_PLACEHOLDER/ d ' ~/.config/nvim/init.lua
#
#      # Uncomment the typescript language server to install it
#      sed -i -e '/tsserver/s/-- //' ~/.config/nvim/init.lua
#      # Install prettierd in Mason - doesn't work
#      # Look into https://github.com/jay-babu/mason-null-ls.nvim
#      # sed -i -e '/tsserver/a  prettierd = {},' ~/.config/nvim/init.lua
#
#      # Map <leader>p to Prettify (:Format buffer with LSP)
#      sed -i -e '/Format current buffer with LSP/a\\n\ \ nmap('\''<leader>p'\'', '\'':%!prettierd %<CR>'\'', '\''Prettier current buffer'\'')' ~/.config/nvim/init.lua
#
#      # Add - to the definition of a word
#      sed -i -e '/modeline/i vim.opt.iskeyword:append('\''-'\'')\n' ~/.config/nvim/init.lua
#
#      # Remove indentation guides and context highlighting
#      sed -i -e "/main = 'ibl'/{ N ; c \ \ \ \ main = 'ibl',\n    opts = { enabled = false, scope = { enabled = false } },"$'\n'"}" ~/.config/nvim/init.lua
#
#      # Add nvim-tree
#      sed -i -e '/import = '\''custom\.plugins'\''/ r '<( { cat <<NVIMTREE
#  {
#    "nvim-tree/nvim-tree.lua",
#    version = "*",
#    lazy = false,
#    dependencies = {
#      "nvim-tree/nvim-web-devicons",
#    },
#    config = function()
#      require("nvim-tree").setup {}
#    end,
#  },
#NVIMTREE
#    } | tr '"' "'" ) ~/.config/nvim/init.lua
#
#      # Disable netrw and add keymap Leader-E for nvim-tree
#      sed -i -e '/maplocalleader / r '<( cat <<NO_NETRW
#
#-- disable netrw at the very start of your init.lua
#vim.g.loaded_netrw = 1
#vim.g.loaded_netrwPlugin = 1
#
#-- set termguicolors to enable highlight groups
#vim.opt.termguicolors = true
#NO_NETRW
#      ) ~/.config/nvim/init.lua
#
#      # Map <leader>f to toogle nvim tree
#      sed -i -e '/Diagnostic keymaps/i\-- NvimTree keymaps\nvim.keymap.set('\''n'\'','\''<leader>f'\'', '\'':NvimTreeToggle<CR>'\'', { desc = '\''Open [f]ile project tree'\'' })' ~/.config/nvim/init.lua
#
#      # Add harpoon
#      sed -i -e '/import = '\''custom\.plugins'\''/ r '<( { cat <<HARPOON
#  {
#    'ThePrimeagen/harpoon',
#    lazy = false,
#    dependencies = {
#      'nvim-lua/plenary.nvim',
#    },
#    config = true,
#    keys = {
#      { '<leader>ha', '<cmd>lua require("harpoon.mark").add_file()<cr>', desc = 'Add file to harpoon' },
#      { '<leader>hr', '<cmd>lua require("harpoon.mark").rm_file()<cr>', desc = 'Remove file from harpoon' },
#      { '<leader>hn', '<cmd>lua require("harpoon.ui").nav_next()<cr>', desc = 'Go to next harpoon mark' },
#      { '<leader>hp', '<cmd>lua require("harpoon.ui").nav_prev()<cr>', desc = 'Go to previous harpoon mark' },
#      { '<leader>hm', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', desc = 'Show harpoon marks' },
#      { '<leader>h1', '<cmd>lua require("harpoon.ui").nav_file(1)<cr>', desc = 'Go to harpoon file 1' },
#      { '<leader>h2', '<cmd>lua require("harpoon.ui").nav_file(2)<cr>', desc = 'Go to harpoon file 2' },
#      { '<leader>h3', '<cmd>lua require("harpoon.ui").nav_file(3)<cr>', desc = 'Go to harpoon file 3' },
#      { '<leader>h4', '<cmd>lua require("harpoon.ui").nav_file(4)<cr>', desc = 'Go to harpoon file 4' },
#    },
#  },
#HARPOON
#      } ) ~/.config/nvim/init.lua
#
#      # Set telescope to path_display to 'smart'
#      sed -i -e '/require('\''telescope'\'').setup {/ { n; a\ \ \ \ path_display = { "smart" },'$'\n''}' ~/.config/nvim/init.lua
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
    cp .vimrc-coc ~/.
    cp .tmux.conf ~/.
}

function installDocker() {
    which docker > /dev/null && return
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update -y
    sudo apt install -y docker-ce

    # sudo apt-get install -y docker.io docker-compose

    sudo usermod -aG docker $USER
    newgrp docker

    grep DOCKER_HIDE_LEGACY_COMMANDS ~/.bashrc > /dev/null 2>&1 || {
        echo 'export DOCKER_HIDE_LEGACY_COMMANDS=true' >> ~/.bashrc
        MESSAGES="${MESSAGES}\nsource ~/.bashrc or relogin to hide docker legacy commands"
    }
    MESSAGES="${MESSAGES}\nIn order for docker to work for anyone but root you need to reboot\e[0m"

    # in case of problems with docker login helpers
    # sudo apt-get remove golang-docker-credential-helpers
}

function showFinishingMessages() {
    echo -e "\n\e[1;91m${MESSAGES}\e[0m"
}

function setupAliases() {
    [ -f ~/.bash_aliases ] && return
    cat > ~/.bash_aliases <<-BASH_ALIASES
alias gs='git status'
alias gd='git diff'
alias sgrep='grep -r --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=public --exclude-dir=lib --exclude-dir=dist'

function aliases() {
    vi ~/.bash_aliases && source ~/.bashrc && echo 'Aliases updated!'
}
BASH_ALIASES
    MESSAGES="${MESSAGES}\nsource ~/.bashrc or relogin for aliases changes to take effect"
}

function setupKeyboardMapping() {
    # This doesn't exist on the server, so we probably don't want to install this
    # setxkbmap tries to connect to DISPLAY...
    # if ! which setxkbmap > /dev/null; then
    #   sudo apt-get install -y x11-xkb-utils
    # fi
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

  # OR
  # copy files into ~/.ssh
  # chmod 0600 /home/doron/.ssh/id_rsa*
  # ssh-add
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
    apt-get -y update
    apt-get install -y openshot-qt
}

function installAudioRecorder() {
    which audio-recorder > /dev/null && return
    apt-add-repository ppa:audio-recorder/ppa
    apt-get -y update
    apt-get install -y audio-recorder
}

function installChrome() {
    which google-chrome-stable > /dev/null && return
    cd ~/Downloads
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
}

function installSkype() {
    which skypeforlinux > /dev/null && return
    cd ~/Downloads
    wget https://go.skype.com/skypeforlinux-64.deb
    sudo apt install -y ./skypeforlinux-64.deb
}

function setupMicrosoftFonts() {
    fc-list -q "Comis Sans" && return

    sudo add-apt-repository multiverse
    sudo apt install -y ttf-mscorefonts-installer
    sudo fc-cache -f -v
}

function installPHPAndComposer() {
    which php > /dev/null || sudo apt-get install -y php unzip php-zip

    # For PDF image support
    php -i | grep 'GD Support' | grep enabled > /dev/null || sudo apt-get -y install php-gd
    # For sendgrid email client
    php -i | grep 'mbstring' | grep enabled  > /dev/null || sudo apt-get -y install php-mbstring
    # For sendgrid email client
    php -i | grep 'curl' > /dev/null || sudo apt-get -y install php-curl
    # For PDO support
    php -i | grep 'pdo_mysql' > /dev/null || sudo apt-get -y install php-pdo-mysql

    if ! which composer > /dev/null; then
      # Taken from https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
      local EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      local ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

      if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
      then
        >&2 echo 'ERROR: Invalid installer checksum'
        rm composer-setup.php
        exit 1
      fi

      php composer-setup.php --quiet
      rm composer-setup.php

      sudo mv composer.phar /usr/local/bin/composer
    fi
}

function installMysqlClient() {
    which mysql > /dev/null || sudo apt-get install -y mysql-client
}

function installDisplayLinkDriver() {
    sudo apt-cache show displaylink-driver > /dev/null 2>&1 && return

    # Based on the instructions on
    # https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu
    # Still needs to be tested after clean install

    cd ~/Downloads
    wget https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb
    sudo apt-get install -y synaptics-repository-keyring.deb
    sudo apt update -y
    sudo apt-get install -y displaylink-driver

    MESSAGES="${MESSAGES}\nReboot the machine for displaylink-driver to work"
}

# ---=== Must install always ===---

installGit
installBuildEssential
installNetTools
installTmux
installTree
installCurl
installJq
installVimAndPlugged
installVolta
installNeoVim
setupProjectsDir
setupDotFiles
setupAliases
#setupSSHKeys
#installDocker

# ---=== Cloud Dev ===---

#installPHPAndComposer
#installMysqlClient

# ---=== Desktop only ===---

#setupKeyboardMapping
#installChrome
#installSkype
#setupMicrosoftFonts
#installObsStudio
#installOpenShot
#installAudioRecorder
#installDisplayLinkDriver

# ---=== Deprecated workflows ===---

#installPostgres

showFinishingMessages
