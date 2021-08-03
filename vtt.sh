apt-get update
sudo apt install -y libssl-dev
sudo apt install unzip
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt install -y nodejs
cd $HOME
sudo mkdir /foundrydata
wget -O foundryvtt.zip $1
sudo unzip foundryvtt.zip
sudo npm install pm2@latest -gls
sudo pm2 start resources/app/main.js -- --dataPath=/foundrydata
