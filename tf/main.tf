# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~> 1.22"
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}

provider "template" {
  version = "~> 2.1"
}

provider "http" {
  version = "~> 1.0"
}

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "ssh_key_data" {}
variable "size" {
    default = "Standard_D4s_v3"
}
variable "disk_size" {
    default = "300"
}
variable "hostname" {
    default = "revdepcheckvm"
}
variable "adminuser" {
    default = "ubuntu"
}
variable "zone" {
    default = "eastus"
}

provider "random" {
    version = "~> 2.0"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "revdepcheckgroup" {
    name     = "revdepcheckResourceGroup"
    location = "${var.zone}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "revdepchecknetwork" {
    name                = "revdepcheckVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.zone}"
    resource_group_name = "${azurerm_resource_group.revdepcheckgroup.name}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "revdepchecksubnet" {
    name                 = "revdepcheckSubnet"
    resource_group_name  = "${azurerm_resource_group.revdepcheckgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.revdepchecknetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "revdepcheckpublicip" {
    name                         = "revdepcheckPublicIP"
    location                     = "${var.zone}"
    resource_group_name          = "${azurerm_resource_group.revdepcheckgroup.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_network_security_group" "revdepchecknsg" {
    name                = "revdepcheckNetworkSecurityGroup"
    location            = "${var.zone}"
    resource_group_name = "${azurerm_resource_group.revdepcheckgroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "${chomp(data.http.myip.body)}/32"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "revdepchecknic" {
    name                      = "revdepcheckNIC"
    location                  = "${var.zone}"
    resource_group_name       = "${azurerm_resource_group.revdepcheckgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.revdepchecknsg.id}"

    ip_configuration {
        name                          = "revdepcheckNicConfiguration"
        subnet_id                     = "${azurerm_subnet.revdepchecksubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.revdepcheckpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.revdepcheckgroup.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "revdepcheckstorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.revdepcheckgroup.name}"
    location                    = "${var.zone}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "revdepcheckvm" {
    name                  = "revdepcheckVM"
    location              = "${var.zone}"
    resource_group_name   = "${azurerm_resource_group.revdepcheckgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.revdepchecknic.id}"]
    vm_size               = "${var.size}"

    storage_os_disk {
        name              = "revdepcheckOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
        disk_size_gb      = "${var.disk_size}"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "revdepcheckvm"
        admin_username = "${var.adminuser}"
        custom_data = "${data.template_cloudinit_config.config.rendered}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.adminuser}/.ssh/authorized_keys"
            key_data = "${var.ssh_key_data}"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.revdepcheckstorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

output "ssh" {
  value = "${formatlist("ssh -L 8080:localhost:80 -o StrictHostKeyChecking=false ${var.adminuser}@%s", azurerm_public_ip.revdepcheckpublicip.*.ip_address)}"
}

output "http" {
  value = "http://localhost:8080"
}
