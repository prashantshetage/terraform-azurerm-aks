// AKS cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = local.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  role_based_access_control {
    enabled = var.role_based_access_control.enabled
    azure_active_directory {
      client_app_id     = var.role_based_access_control.client_app_id
      server_app_id     = var.role_based_access_control.server_app_id
      server_app_secret = var.role_based_access_control.server_app_secret
      tenant_id         = var.role_based_access_control.tenant_id
    }
  }

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      # remove any new lines using the replace interpolation function
      key_data = replace(var.admin_public_ssh_key, "\n", "")
    }
  }

  default_node_pool {
    name                  = var.default_node_pool.name
    vm_size               = var.default_node_pool.vm_size
    availability_zones    = var.default_node_pool.availability_zones
    enable_auto_scaling   = var.default_node_pool.enable_auto_scaling
    enable_node_public_ip = var.default_node_pool.enable_node_public_ip
    max_pods              = var.default_node_pool.max_pods
    node_labels           = var.default_node_pool.node_labels
    node_taints           = var.default_node_pool.node_taints
    os_disk_size_gb       = var.default_node_pool.os_disk_size_gb
    type                  = var.default_node_pool.type
    vnet_subnet_id        = var.default_node_pool.vnet_subnet_id
    min_count             = var.default_node_pool.min_count
    max_count             = var.default_node_pool.max_count
    node_count            = var.default_node_pool.node_count
    tags                  = var.default_node_pool.tags
  }

  service_principal {
    client_id     = var.service_principal_client_id
    client_secret = var.service_principal_client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  network_profile {
    network_plugin     = var.network_profile.network_plugin
    network_policy     = var.network_profile.network_policy
    dns_service_ip     = var.network_profile.dns_service_ip
    docker_bridge_cidr = var.network_profile.docker_bridge_cidr
    pod_cidr           = var.network_profile.pod_cidr
    service_cidr       = var.network_profile.service_cidr
    load_balancer_sku  = var.network_profile.load_balancer_sku
  }

  tags       = merge(var.resource_tags, var.deployment_tags)
  depends_on = [var.it_depends_on]

  lifecycle {
    ignore_changes = [
      tags,
      XXXXXXXXXXXXXXX
    ]
  }

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************


