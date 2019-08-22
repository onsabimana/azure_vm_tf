provider "azurerm" {
  version = "=1.28.0"
}

variable "prefix" {
  default = "onsabimana"
}

data "azurerm_resource_group" "main" {
  name = "temp-test"
}

data "azurerm_network_interface" "main" {
  name                = "myVMVMNic"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
}

data "azurerm_public_ip" "main" {
  name                = "myVMPublicIP"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${data.azurerm_resource_group.main.location}"
  resource_group_name   = "${data.azurerm_resource_group.main.name}"
  network_interface_ids = ["${data.azurerm_network_interface.main.id}"]
  vm_size               = "Standard_DS1_v2"

  # Delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.admin_hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key_path}/epicon_test_vm.pub")}"
    }
  }

  # This is to ensure SSH comes up before we run the local exec.
  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      host        = "${data.azurerm_public_ip.main.fqdn}"
      user        = "${var.admin_username}"
      private_key = "${file("${var.ssh_key_path}/epicon_test_vm")}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/jetty.yml --private-key ${var.ssh_key_path}"
  }

  tags = {
    environment = "test"
  }
}
