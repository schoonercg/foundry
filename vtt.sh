#!/bin/sh
apt-get update
sudo apt install -y libssl-dev
sudo apt install unzip
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt install -y nodejs
cd /home/adminuser
sudo mkdir /foundrydata
sudo wget -O /home/adminuser/foundryvtt.zip $1
sudo unzip /home/adminuser/foundryvtt.zip
sudo npm install pm2@latest -gls
sudo pm2 start /home/adminuser/foundryvtt/resources/app/main.js -- --dataPath=/foundrydata
