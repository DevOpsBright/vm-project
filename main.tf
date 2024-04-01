resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.resource_group_name 
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetname
  address_space       = var.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "v_subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.ipprefixes
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "Bless-Onboarding-Public-IP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name 
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "nsg" {
  name                = "Bless-Onboarding-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic_ip"
    subnet_id                     =  azurerm_subnet.v_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_nic_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
  rsa_bits    = 4096
}


# Create storage account for boot diagnostics
resource "azurerm_linux_virtual_machine" "I-vm" {
  name                     = var.hostname
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  size            = "Standard_DS1_v2"
  admin_username =  "adminuser"
  disable_password_authentication = true
  computer_name =  var.hostname
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username = "adminuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    name                 = "OSDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb =  30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "data_disk" {
  name  =   "Bless_Onboarding-Data-Disk"
  location =   azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  storage_account_type =  "Standard_LRS"
  create_option =   "Empty"
  disk_size_gb =   500 
}

# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_data_disk_attachment" "attach-disk-to-vm" {
  managed_disk_id     =      azurerm_managed_disk.data_disk.id
  virtual_machine_id   =       azurerm_linux_virtual_machine.I-vm.id
  lun                = "10"
  caching = "ReadWrite"  
}

//data "external" "kernel_version" {
 //   program =["bash", "./scripts/kernel_version.sh"]
   // depends_on =[azurerm_linux_virtual_machine.I-vm]
//}