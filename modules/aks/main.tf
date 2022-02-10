resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  role_based_access_control {
    enabled = true
  }

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = var.vm_size
  }
  # service_principal {
  #   client_id     = var.client_id
  #   client_secret = var.client_secret
  # }
  identity {
    type = "SystemAssigned"
  }
  addon_profile {
    oms_agent {
      enabled = false
      # log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
    }
  }

  network_profile {
    load_balancer_sku = "Basic"
    network_plugin    = "kubenet"
  }

  # network_profile {
  #   network_plugin    = "kubenet"
  #   load_balancer_sku = "Standard"
  #   load_balancer_profile {
  #     outbound_ip_address_ids = [var.public_ip_id]
  #   }
  # }
  tags = {
    Environment = "Development"
  }
}
resource "azurerm_role_assignment" "k8s_to_acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}
