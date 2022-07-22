terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }

  # Note that variable values are not allowed for the backend. The
  # resource group, storage account, and container names must all be
  # hardcoded. Terraform will automatically suffix the key with the
  # current Terraform workspace/environment.
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

##
## Resource group
##
data "azurerm_resource_group" "persostack" {
  name = var.resource_group_name
}

data "azurerm_subnet" "public_subnet" {
  name                 = var.public_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_subnet" "private_subnet" {
  name                 = var.private_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group_name
}

data "azurerm_ssh_public_key" "ssh_public_key" {
  name                = var.ssh_public_key_name
  resource_group_name = var.resource_group_name
}

##
## Bastion VM
##
# Network interface
resource "azurerm_network_interface" "bastion" {
  count               = var.create_bastion_server == true ? 1 : 0
  name                = "${lower(var.project)}-${lower(var.env)}-bastion-nic"
  location            = data.azurerm_resource_group.persostack.location
  resource_group_name = data.azurerm_resource_group.persostack.name

  ip_configuration {
    name                          = "${lower(var.project)}-${lower(var.env)}-bastion-nic-config"
    subnet_id                     = data.azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}

data "azurerm_network_interface" "bastion" {
  count               = var.create_bastion_server == true ? 0 : 1
  name                = "persostack-${lower(var.env)}-bastion-nic"
  resource_group_name = data.azurerm_resource_group.persostack.name
}


# Bastion VM
resource "azurerm_virtual_machine" "bastion" {
  count               = var.create_bastion_server == true ? 1 : 0
  name                = "${lower(var.project)}-${lower(var.env)}-bastion-vm"
  location            = data.azurerm_resource_group.persostack.location
  resource_group_name = data.azurerm_resource_group.persostack.name

  network_interface_ids = [azurerm_network_interface.bastion[count.index].id]
  vm_size               = var.bastion_vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.bastion_vm_os_publisher
    offer     = var.bastion_vm_os_offer
    sku       = var.bastion_vm_os_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "${lower(var.project)}-${lower(var.env)}-bastion-os-disk0"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = var.bastion_vm_os_disk_size_gb
  }

  storage_data_disk {
    name              = "${lower(var.project)}-${lower(var.env)}-bastion-data-disk0"
    create_option     = "Empty"
    disk_size_gb      = var.bastion_vm_disk_size_gb
    lun               = 0
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${lower(var.project)}-${lower(var.env)}-bastion"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = data.azurerm_ssh_public_key.ssh_public_key.public_key
      path     = format("/home/%s/.ssh/authorized_keys", var.admin_username)
    }
  }

  provisioner "local-exec" {
    command = "echo hello world"
  }

}

##
## Docker server VM
##

# Network interface
resource "azurerm_network_interface" "docker_server" {
  count               = var.create_docker_server == true ? 1 : 0
  name                = "${lower(var.project)}-${lower(var.env)}-docker-server-nic"
  location            = data.azurerm_resource_group.persostack.location
  resource_group_name = data.azurerm_resource_group.persostack.name

  ip_configuration {
    name                          = "${lower(var.project)}-${lower(var.env)}-docker-server-nic-config"
    subnet_id                     = data.azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Docker server VM
resource "azurerm_virtual_machine" "docker_server" {
  count               = var.create_docker_server == true ? 1 : 0
  name                = "${lower(var.project)}-${lower(var.env)}-docker-server-vm"
  location            = data.azurerm_resource_group.persostack.location
  resource_group_name = data.azurerm_resource_group.persostack.name

  network_interface_ids = [azurerm_network_interface.docker_server[count.index].id]
  vm_size               = var.docker_server_vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.docker_server_vm_os_publisher
    offer     = var.docker_server_vm_os_offer
    sku       = var.docker_server_vm_os_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "${lower(var.project)}-${lower(var.env)}-docker-server-os-disk0"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = var.docker_server_vm_os_disk_size_gb
  }

  storage_data_disk {
    name              = "${lower(var.project)}-${lower(var.env)}-docker-server-data-disk0"
    create_option     = "Empty"
    disk_size_gb      = var.docker_server_vm_disk_size_gb
    lun               = 0
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${lower(var.project)}-${lower(var.env)}-docker-server"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = data.azurerm_ssh_public_key.ssh_public_key.public_key
      path     = format("/home/%s/.ssh/authorized_keys", var.admin_username)
    }
  }

  # Add a user assigned identity to the VM if one is specifiec
  dynamic "identity" {
    for_each = var.docker_server_vm_user_assigned_identity_id == "" ? [] : [var.docker_server_vm_user_assigned_identity_id]

    content {
      type         = "UserAssigned"
      identity_ids = [identity.value]
    }
  }
}

##
## Devops server VM
##

# Network interface
resource "azurerm_network_interface" "devops_server" {
  count               = var.create_devops_server == true ? 1 : 0
  name                = "${lower(var.project)}-${lower(var.env)}-devops-server-nic"
  location            = data.azurerm_resource_group.persostack.location
  resource_group_name = data.azurerm_resource_group.persostack.name

  ip_configuration {
    name                          = "${lower(var.project)}-${lower(var.env)}-devops-server-nic-config"
    subnet_id                     = data.azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Docker server VM
resource "azurerm_virtual_machine" "devops_server" {
  count               = var.create_devops_server == true ? 1 : 0
  name                = "${lower(var.project)}-${lower(var.env)}-devops-server-vm"
  location            = data.azurerm_resource_group.persostack.location
  resource_group_name = data.azurerm_resource_group.persostack.name

  network_interface_ids = [azurerm_network_interface.devops_server[count.index].id]
  vm_size               = var.devops_server_vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.devops_server_vm_os_publisher
    offer     = var.devops_server_vm_os_offer
    sku       = var.devops_server_vm_os_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "${lower(var.project)}-${lower(var.env)}-devops-server-server-os-disk0"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = var.devops_server_vm_os_disk_size_gb
  }

  storage_data_disk {
    name              = "${lower(var.project)}-${lower(var.env)}-devops-server-data-disk0"
    create_option     = "Empty"
    disk_size_gb      = var.devops_server_vm_disk_size_gb
    lun               = 0
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${lower(var.project)}-${lower(var.env)}-devops-server"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = data.azurerm_ssh_public_key.ssh_public_key.public_key
      path     = format("/home/%s/.ssh/authorized_keys", var.admin_username)
    }
  }

  # Add a user assigned identity to the VM if one is specifiec
  dynamic "identity" {
    for_each = var.devops_server_vm_user_assigned_identity_id == "" ? [] : [var.devops_server_vm_user_assigned_identity_id]

    content {
      type         = "UserAssigned"
      identity_ids = [identity.value]
    }
  }
}

locals {
  user_pub_keys = toset(compact((split("\n", file("~/.ssh/users/${lower(var.env)}/users.txt")))))
}


data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "persostack-kv-common" {
  name                = "persostack-${lower(var.env)}-common"
  resource_group_name = data.azurerm_resource_group.persostack.name
}

data "azurerm_key_vault" "persostack-kv-developers" {
  name                = "persostack-${lower(var.env)}-devlprs"
  resource_group_name = data.azurerm_resource_group.persostack.name
}

data "azurerm_key_vault" "persostack-kv-github" {
  name                = "persostack-${lower(var.env)}-github"
  resource_group_name = data.azurerm_resource_group.persostack.name
}

data "azurerm_key_vault_secret" "persostack-kv-sec-public-keys" {
  for_each     = local.user_pub_keys
  name         = each.key
  key_vault_id = data.azurerm_key_vault.persostack-kv-developers.id
}

data "azurerm_key_vault_secret" "persostack-kv-sec-fernet-keys" {
  for_each     = local.user_pub_keys
  name         = format("%s-fernetkey", each.key)
  key_vault_id = data.azurerm_key_vault.persostack-kv-developers.id
}

resource "local_sensitive_file" "create_user_public_keys" {
  for_each = local.user_pub_keys
  content  = data.azurerm_key_vault_secret.persostack-kv-sec-public-keys[each.key].value
  filename = format("${path.module}/../../ansible/roles/users/files/public_keys/%s.pub", each.key)
}

resource "local_sensitive_file" "create_user_fernet_keys" {
  for_each = local.user_pub_keys
  content  = data.azurerm_key_vault_secret.persostack-kv-sec-fernet-keys[each.key].value
  filename = format("${path.module}/../../ansible/secret_vars/.%s.fernetkey", each.key)
}

data "azurerm_key_vault_secret" "persostack_kv_sec_fernetkey_common" {
  name         = "persostack-${lower(var.env)}-airflow-fernet-key"
  key_vault_id = data.azurerm_key_vault.persostack-kv-common.id
}

resource "local_sensitive_file" "create_fernetkey_common" {
  content  = data.azurerm_key_vault_secret.persostack_kv_sec_fernetkey_common.value
  filename = format("${path.module}/../../ansible/secret_vars/${lower(var.env)}_common_fernetkey")
}

data "azurerm_key_vault_secret" "persostack_kv_sec_databricks" {
  name         = "persostack-${lower(var.env)}-databricks-token"
  key_vault_id = data.azurerm_key_vault.persostack-kv-common.id
}

resource "local_sensitive_file" "persostack_kv_sec_databricks" {
  content  = data.azurerm_key_vault_secret.persostack_kv_sec_databricks.value
  filename = format("${path.module}/../../credentials/localfiles/.${lower(var.env)}_common_databricks_token")
}

data "azurerm_key_vault_secret" "persostack_kv_sec_airflow_password" {
  name         = "persostack-${lower(var.env)}-airflow-password"
  key_vault_id = data.azurerm_key_vault.persostack-kv-common.id
}

resource "local_sensitive_file" "persostack_kv_sec_airflow_password" {
  content  = data.azurerm_key_vault_secret.persostack_kv_sec_airflow_password.value
  filename = format("${path.module}/../../ansible/secret_vars/.${lower(var.env)}_common_airflow_password")
}

data "azurerm_key_vault_secret" "persostack_kv_sec_dev_db_password" {
  name         = "persostack-${lower(var.env)}-airflow-db-password"
  key_vault_id = data.azurerm_key_vault.persostack-kv-common.id
}

resource "local_sensitive_file" "persostack_kv_sec_dev_db_password" {
  content  = data.azurerm_key_vault_secret.persostack_kv_sec_dev_db_password.value
  filename = format("${path.module}/../../ansible/secret_vars/.${lower(var.env)}_common_db_password")
}

data "azurerm_key_vault_secret" "persostack_kv_sec_server_private_key" {
  name         = "persostack-${lower(var.env)}-server-private-key"
  key_vault_id = data.azurerm_key_vault.persostack-kv-common.id
}

resource "local_sensitive_file" "persostack_kv_sec_server_private_key" {
  content  = data.azurerm_key_vault_secret.persostack_kv_sec_server_private_key.value
  filename = format("~/.ssh/${lower(var.env)}_ssh_private_key")
}

data "template_file" "databrickscfg" {
  template = file("${path.module}/databrickscfg.template")
  vars = {
    databricks_instance_url = chomp(var.databricks_instance_url)
    databricks_token        = chomp(data.azurerm_key_vault_secret.persostack_kv_sec_databricks.value)
  }
}

resource "local_sensitive_file" "persostack_create_databrickscfg" {
  content  = data.template_file.databrickscfg.rendered
  filename = format("${path.module}/../../credentials/localfiles/.databrickscfg")
}

data "template_file" "airflow_secrets" {
  template = file("${path.module}/../../ansible/secret_vars/persostack-docker-services-template.yml")
  vars = {
    airflow_fernetkey    = chomp(data.azurerm_key_vault_secret.persostack-kv-sec-fernet-keys[var.user].value)
    airflow_web_password = chomp(data.azurerm_key_vault_secret.persostack_kv_sec_airflow_password.value)
    airflow_db_password  = chomp(data.azurerm_key_vault_secret.persostack_kv_sec_dev_db_password.value)
    mlflow_db_password   = chomp(data.azurerm_key_vault_secret.persostack_kv_sec_dev_db_password.value)
  }
}

resource "local_sensitive_file" "airflow_secrets" {
  content  = data.template_file.airflow_secrets.rendered
  filename = format("${path.module}/../../ansible/secret_vars/persostack-docker-services.yml")
}

data "template_file" "inventory" {
  template = file("${path.module}/../../ansible/inventory/azure/env.template")
  vars = {
    bastion_server       = chomp(var.create_bastion_server == true ? azurerm_network_interface.bastion[0].private_ip_address : data.azurerm_network_interface.bastion[0].private_ip_address)
    docker_server        = chomp(var.create_docker_server == true ? azurerm_network_interface.docker_server[0].private_ip_address : "")
    ssh_private_key_file = format("~/.ssh/.${lower(var.env)}_ssh_private_key")
  }
}

resource "local_sensitive_file" "inventory" {
  content  = data.template_file.inventory.rendered
  filename = format("${path.module}/../../ansible/inventory/azure/${lower(var.env)}-${var.user}.yml")
}

resource "time_sleep" "wait_100_seconds" {
  depends_on = [azurerm_network_interface.bastion[0], azurerm_network_interface.docker_server[0]]

  create_duration = "100s"
}

resource "time_sleep" "wait_260_seconds" {
  depends_on = [azurerm_network_interface.bastion[0], azurerm_network_interface.docker_server[0]]

  create_duration = "260s"
}

resource "local_sensitive_file" "ansible_bastion_execution" {
  count    = var.create_bastion_server == true ? 1 : 0
  content  = data.template_file.inventory.rendered
  filename = format("${path.module}/../../ansible/inventory/azure/test_bastion.ansible")

  depends_on = [
    local_sensitive_file.inventory,
    local_sensitive_file.airflow_secrets,
    local_sensitive_file.persostack_create_databrickscfg,
    local_sensitive_file.persostack_kv_sec_server_private_key,
    azurerm_network_interface.bastion[0],
    azurerm_network_interface.docker_server[0],
    time_sleep.wait_100_seconds
  ]

  provisioner "local-exec" {
    command = "./ansible.sh $bastion_server_ip, $docker_server_ip $yaml_file ssh_private_key_file"

    environment = {
      bastion_server_ip    = tostring(var.create_bastion_server == true ? azurerm_network_interface.bastion[0].private_ip_address : data.azurerm_network_interface.bastion[0].private_ip_address)
      docker_server_ip     = tostring(azurerm_network_interface.docker_server[0].private_ip_address)
      yaml_file            = format("inventory/azure/${lower(var.env)}-${var.user}.yml")
      ssh_private_key_file = format("~/.ssh/.${lower(var.env)}_ssh_private_key")
    }
  }

}

resource "local_sensitive_file" "ansible_docker_execution" {
  count    = var.create_docker_server == true ? 1 : 0
  content  = data.template_file.inventory.rendered
  filename = format("${path.module}/../../ansible/inventory/azure/test_docker.ansible")

  depends_on = [
    local_sensitive_file.inventory,
    local_sensitive_file.airflow_secrets,
    local_sensitive_file.persostack_create_databrickscfg,
    local_sensitive_file.persostack_kv_sec_server_private_key,
    azurerm_network_interface.bastion[0],
    azurerm_network_interface.docker_server[0],
    time_sleep.wait_100_seconds,
    time_sleep.wait_260_seconds
  ]

  provisioner "local-exec" {
    command = "./ansible_docker.sh $bastion_server_ip, $docker_server_ip $yaml_file ssh_private_key_file"

    environment = {
      bastion_server_ip    = tostring(var.create_bastion_server == true ? azurerm_network_interface.bastion[0].private_ip_address : data.azurerm_network_interface.bastion[0].private_ip_address)
      docker_server_ip     = tostring(azurerm_network_interface.docker_server[0].private_ip_address)
      yaml_file            = format("inventory/azure/${lower(var.env)}-${var.user}.yml")
      ssh_private_key_file = format("~/.ssh/.${lower(var.env)}_ssh_private_key")
    }
  }

}



