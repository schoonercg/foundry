#wget https://aka.ms/dependencyagentlinux
#sh InstallDependencyAgent-Linux64.bin -s

##install and apply the CEF collector
apt-get update
sudo apt install -y libssl-dev
sudo apt install unzip
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt install -y nodejs
cd $HOME
sudo mkdir foundryvtt
sudo mkdir /foundrydata
#sudo mount /dev/sdc1 /foundrydata
wget -O foundryvtt.zip $1
sudo unzip foundryvtt.zip
#node resources/app/main.js --dataPath=$HOME/foundrydata
sudo npm install pm2@latest -gls
sudo pm2 start resources/app/main.js -- --dataPath=/foundrydata