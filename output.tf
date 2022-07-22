##
## Bastion VM outputs
output "bastion_vm_external_ip" {
  description = "External IP of the bastion VM"
  value       = var.create_bastion_server == true ? azurerm_network_interface.bastion[0].private_ip_address : data.azurerm_network_interface.bastion[0].private_ip_address
  #value       = azurerm_network_interface.bastion.private_ip_address
}

##
## Docker server VM outputs
output "docker_services_vm_internal_ip" {
  description = "Internal IP of the docker services VM"
  value       = var.create_docker_server == true ? azurerm_network_interface.docker_server[0].private_ip_address : null
  #value       = azurerm_network_interface.docker_server.private_ip_address
}

##
## DevOps server VM outputs
output "devops_services_vm_internal_ip" {
  description = "Internal IP of the devops services VM"
  value       = var.create_devops_server == true ? azurerm_network_interface.devops_server[0].private_ip_address : null
  #value       = azurerm_network_interface.docker_server.private_ip_address
}
