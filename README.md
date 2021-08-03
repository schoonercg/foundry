# foundry
Terraform Build scripts for Foundry Virtual Tabletop


Download main and variables.tf

copy your foundry download url for Linux/NodeJS from 

https://foundryvtt.com/community/yourusername/licenses

terraform apply -var 'foundryurl="https://foundryvtt.s3.amazonaws.com/releases/0.8.8/foundryvtt-0.8.8.zip?AWSAccessKeyIdtruncated"'

or wget the install script for ubuntu and run it on your own ubuntu instances

wget https://raw.githubusercontent.com/schoonercg/foundry/main/vtt.sh

chmod 777 ./vtt.sh 
./vtt.sh "https://foundryvtt.s3.amazonaws.com/releases/0.8.8/foundryvtt-0.8.8.zip?AWSAccessKeyIdtruncated"
