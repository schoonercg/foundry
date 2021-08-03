# Configure the Azure provider
terraform {
  backend "local" {
#https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage
#variables are not allowed here    
  }
 
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}
provider "azurerm" {
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

  # subscription_id = "..."
  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."
}

resource "azurerm_resource_group" "main" {
  name     = "${var.resourcegroup}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.virtualnetwork}"
  resource_group_name = azurerm_resource_group.main.name
  location = "${var.location}"
  address_space       = ["10.220.255.0/26"]
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.subnet}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.220.255.0/27"]
}
resource "azurerm_network_security_group" "vttservernsg" {
  name                = "vttservernsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "ldserverssh" {
  name                        = "vttserverssh"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix    = "${var.WAN_IPs}"
  destination_address_prefixes  = [
    azurerm_network_interface.vtthost.private_ip_address
  ]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.vttservernsg.name
}

resource "azurerm_network_security_rule" "vttserverweb" {
  name                        = "vttserverweb"
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "30000"
  source_address_prefix    = "${var.WAN_IPs}"
  destination_address_prefixes  = [
    azurerm_network_interface.vtthost.private_ip_address
  ]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.vttservernsg.name
}

resource "azurerm_network_interface_security_group_association" "samain" {
  network_interface_id      = azurerm_network_interface.vtthost.id
  network_security_group_id = azurerm_network_security_group.vttservernsg.id
}

resource "azurerm_public_ip" "vttpip" {
  name                = "foundrypip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}
output "pipoutput"{
  value = azurerm_public_ip.vttpip.ip_address
}
resource "azurerm_network_interface" "vtthost" {
  name                = "${var.prefix}-vttnic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vttpip.id
  }
}

resource "azurerm_linux_virtual_machine" "vtthost" {
  name                            = "${var.prefix}-vttvm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.vmsize
  admin_username                  = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.vttkey.public_key_openssh
  }
  disable_password_authentication = true
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.vtt.primary_blob_endpoint
    }
  #source_image_id = var.Image_ID
  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  provision_vm_agent = true
  network_interface_ids = [
    azurerm_network_interface.vtthost.id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 200
  }
  identity {
    type = "SystemAssigned"
  }
}



resource "azurerm_virtual_machine_extension" "vttinstall-script" {
  name                         = "custom-script"
  virtual_machine_id    = azurerm_linux_virtual_machine.vtthost.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = <<-BASE_SETTING
  {
  "fileUris" : ["https://raw.githubusercontent.com/schoonercg/foundry/main/vtt.sh"],
  "commandToExecute" : "sh vtt.sh ${var.foundryurl}"
  }
BASE_SETTING
  depends_on = [azurerm_linux_virtual_machine.vtthost]
}


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "KV-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                        = "premium"
  enabled_for_template_deployment = true
  enabled_for_deployment          = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "create",
      "delete",
      "get",
      "update",
    ]

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "list",
      "get",
      "delete",
      "purge",
      "recover"
    ]

    storage_permissions = [
      "set",
    ]
  }
}

resource "tls_private_key" "vttkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "vttkey" {
  name         = "vttkey"
  value        = base64encode("${tls_private_key.vttkey.private_key_pem}")
  key_vault_id = azurerm_key_vault.main.id
}

resource "local_file" "private_key" {
    content  = tls_private_key.vttkey.private_key_pem
    filename = "c:/users/danielgarza/.ssh/vttkey.pem"
}

#storage account

resource "random_string" "random" {
  length = 6
  special = false
  upper = false
}
resource "azurerm_storage_account" "vtt" {
  name                     = "sa${random_string.random.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}