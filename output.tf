# output.tf

output "hostname" {
  value = azurerm_linux_virtual_machine.I-vm.name
}

output "location" {
  value = azurerm_resource_group.rg.location
}

output "vnetname" {
  value = azurerm_virtual_network.vnet.name
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
