# Output the public IP address of the Load Balancer
output "scc_lb_pip_public_ip" {
  value = azurerm_public_ip.scc_lb_pip.ip_address
}