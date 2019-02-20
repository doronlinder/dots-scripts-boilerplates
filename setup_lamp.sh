#!/bin/bash
set -e
MESSAGES=""

function updatePackages() {
  apt update
}

function setupLAMP() {
  systemctl status apache2 > /dev/null && exit
  apt-get install -y lamp-server^
}

function showFinishingMessages() {
  which google-chrome > /dev/null || MESSAGES="${MESSAGES}\nInstall Chrome manually"
  echo -e "\n\e[1;91m${MESSAGES}\e[0m"
}

function mysqlChangeRootAuth() {
  read -esp "Please enter new root mysql password: " rootpass
  echo
  mysql -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '$rootpass'; FLUSH PRIVILEGES;"
}

function createVimAdventuresDB() {
  read -esp "Please enter root mysql password: " rootpass
  mysql -u root -p${rootpass} -e "CREATE DATABASE vim_adventures;"
  read -ep "Please enter vim_adventures mysql user: " mysqluser
  echo
  read -esp "Please enter vim_adventures mysql user password: " mysqluserpassword
  echo
  mysql -u root -p${rootpass} -e "CREATE USER '${mysqluser}'@'localhost' IDENTIFIED BY '${mysqluserpassword}'; GRANT ALL PRIVILEGES ON vim_adventures.* TO '${mysqluser}'@'localhost'; FLUSH PRIVILEGES;"
}

updatePackages
setupLAMP
mysqlChangeRootAuth
createVimAdventuresDB
showFinishingMessages
