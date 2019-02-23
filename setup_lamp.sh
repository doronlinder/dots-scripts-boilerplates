#!/bin/bash
set -e
MESSAGES=""

function updatePackages() {
  sudo apt update
}

function setupLAMP() {
  sudo systemctl status apache2 > /dev/null && exit
  sudo apt-get install -y lamp-server^
  sudo a2enmod rewrite headers
  sudo systemctl restart apache2
}

function allowZeroDatesInMySql() {
  grep "Allow 00-00-0000" /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null && exit
  sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf <<-ALLOW_ZEROS_IN_DATE

# Allow 00-00-0000 00:00:00 as a valid date!
#sql_mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
sql_mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
ALLOW_ZEROS_IN_DATE
  sudo systemctl restart mysql
}

function showFinishingMessages() {
  which google-chrome > /dev/null || MESSAGES="${MESSAGES}\nInstall Chrome manually"
  echo -e "\n\e[1;91m${MESSAGES}\e[0m"
}

function mysqlChangeRootAuth() {
  read -esp "Please enter new root mysql password: " rootpass
  echo
  sudo mysql -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '$rootpass'; FLUSH PRIVILEGES;"
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
allowZeroDatesInMySql
mysqlChangeRootAuth
createVimAdventuresDB
showFinishingMessages
