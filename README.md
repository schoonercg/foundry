# foundry
Terraform Build scripts for Foundry Virtual Tabletop on Azure VM
Ubuntu
Key based ssh access - no passwords

Download main and variables.tf
copy your foundry download url for Linux/NodeJS from 
https://foundryvtt.com/community/yourusername/licenses
terraform apply -var 'foundryurl="https://foundryvtt.s3.amazonaws.com/releases/0.8.8/foundryvtt-0.8.8.zip?AWSAccessKeyIdtruncated"'

or wget the install script for ubuntu and run it on your own ubuntu instances
wget https://raw.githubusercontent.com/schoonercg/foundry/main/vtt.sh
chmod 777 ./vtt.sh 
./vtt.sh "https://foundryvtt.s3.amazonaws.com/releases/0.8.8/foundryvtt-0.8.8.zip?AWSAccessKeyIdtruncated"




Running Terraform quick-start
Install the Azure CLI 
https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
https://aka.ms/installazurecliwindows
Download Terraform Binary
https://releases.hashicorp.com/terraform/1.0.2/terraform_1.0.2_windows_amd64.zip
Add terraform.exe to path
set PATH=%PATH%;C:\terraform\
az login 
Set-Az Context 
terraform init : installs modules and downloads required resource providers such as AzureRM
terraform plan : prepares the scripts for execution, essentially a dry run to verify code syntax
terraform apply : will run a plan and offer a yes or no option to deploy the changes. 
terraform destroy : will destroy the created and managed resources 
