output "public_dns" {
  value = "${data.azurerm_public_ip.main.fqdn}"
}

output "App_Server_URL" {
  value = "http://${data.azurerm_public_ip.main.fqdn}"
}
