variable admin_hostname {
  default = "hostname"
}

variable admin_username {
  default = "adminuser"
}

variable admin_password {
  default = "Password1234!"
}

variable "ssh_key_path" {
  description = "Path to your ssh key on the local system."
  default     = "~/.ssh"
}
