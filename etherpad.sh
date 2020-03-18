#!/bin/bash
#Etherpad-lite
homedir=/home/ # folder to install etherpad.
users=username # Username use for etherpad dont use root.
#Install NodeJS
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs
#change folder to install etherpad
cd $homedir
git clone --branch master git://github.com/ether/etherpad-lite.git
cd etherpad-lite
chown -R $users:users $homedir
./bin/run.sh
# https://github.com/ether/etherpad-lite/wiki/How-to-put-Etherpad-Lite-behind-a-reverse-Proxy
