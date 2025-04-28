# Data source for existing Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "rg-1" {
  name = "ND-AVD-deployment"
}

# Get existing NICs of both Workstation machines
# Note: These'd be faster if we import both NICs rather than using data...
data "azurerm_network_interface" "ws1_nic" {
  name                = var.ws1_nic_name
  resource_group_name = data.azurerm_resource_group.rg-1.name
}

data "azurerm_network_interface" "ws2_nic" {
  name                = var.ws2_nic_name
  resource_group_name = data.azurerm_resource_group.rg-1.name
}

# Public IP for Load Balancer
resource "azurerm_public_ip" "scc_lb_pip" {
  name                = "scc-lb-publicip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    ticket = "SA-276"
  }
}

# Load Balancer
resource "azurerm_lb" "scc_lb" {
  name                = "scc-ha-loadbalancer"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags = {
    ticket = "SA-276"
  }

  frontend_ip_configuration {
    name                 = "scc-lb-frontend"
    public_ip_address_id = azurerm_public_ip.scc_lb_pip.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "scc_backend_pool" {
  name            = "scc-vm-backend-pool"
  loadbalancer_id = azurerm_lb.scc_lb.id
}

# Health Probe(s)
resource "azurerm_lb_probe" "scc_rdp_probe" {
  name                = "scc-rdp-probe"
  loadbalancer_id     = azurerm_lb.scc_lb.id
  protocol            = "Tcp"
  port                = 3389
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load Balancing Rule(s)
resource "azurerm_lb_rule" "scc_rdp_rule" {
  name                           = "scc-rdp-rule"
  loadbalancer_id                = azurerm_lb.scc_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "scc-lb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.scc_backend_pool.id]
  probe_id                       = azurerm_lb_probe.scc_rdp_probe.id
  idle_timeout_in_minutes        = 30
  enable_tcp_reset               = true
  enable_floating_ip             = false
  load_distribution              = "SourceIP"
}

# Associate NICs with Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "scc_ws1_pool" {
  network_interface_id    = data.azurerm_network_interface.ws1_nic.id
  ip_configuration_name   = data.azurerm_network_interface.ws1_nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.scc_backend_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "scc_ws2_pool" {
  network_interface_id    = data.azurerm_network_interface.ws2_nic.id
  ip_configuration_name   = data.azurerm_network_interface.ws2_nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.scc_backend_pool.id
}
