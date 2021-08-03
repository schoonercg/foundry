#!/bin/sh
apt-get update
sudo apt-get install -y libssl-dev unzip nodejs
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
cd /home/adminuser
sudo mkdir /foundrydata
sudo mkdir /home/adminuser/foundryvtt
sudo wget -O /home/adminuser/foundryvtt.zip $1
sudo unzip /home/adminuser/foundryvtt.zip -d /home/adminuser/foundryvtt
sudo npm install pm2@latest -gls
sudo pm2 start /home/adminuser/foundryvtt/resources/app/main.js -- --dataPath=/foundrydata
