
// AKS cluster
variable "resource_group_name" {
  type        = string
  description = "(Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist"
}

variable "location" {
  type        = string
  description = "(Required) The location where the Managed Kubernetes Cluster should be created"
}

variable "dns_prefix" {
  type        = string
  description = "(Required) DNS prefix specified when creating the managed cluster"
}

// Addon Profile
variable "addon_profile_aci_connector_linux" {
  type = object({
    enabled     = bool   #(Required) Is the virtual node addon enabled
    subnet_name = string #(Optional) The subnet name for the virtual nodes to run. This is required when aci_connector_linux enabled argument is set to true
  })
  description = "(Optional) aci_connector_linux block"
  default = {
    enabled     = false
    subnet_name = null
  }
}
variable "addon_profile_azure_policy" {
  type = object({
    enabled = bool #(Required) Is the Azure Policy for Kubernetes Add On enabled?
  })
  description = "(Optional) Azure Policy makes it possible to manage and report on the compliance state of AKS cluster"
  default = {
    enabled = false
  }
}
variable "addon_profile_http_application_routing" {
  type = object({
    enabled = bool #(Required) Is HTTP Application Routing Enabled?
  })
  description = "TBD"
  default = {
    enabled = false
  }
}
variable "addon_profile_kube_dashboard" {
  type = object({
    enabled = bool #(Required) Is the Kubernetes Dashboard enabled?
  })
  description = "TBD"
  default = {
    enabled = false
  }
}
variable "addon_profile_oms_agent" {
  type = object({
    enabled                    = bool   #(Required) Is the OMS Agent Enabled?
    log_analytics_workspace_id = string #(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to.
    #oms_agent_identity
  })
  description = "TBD"
  default = {
    enabled                    = false
    log_analytics_workspace_id = null
  }
}

varibale "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "(Optional) The IP ranges to whitelist for incoming traffic to the masters"
  default     = []
}

// Auto Scaler
variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups      = bool   #Detect similar node groups and balance the number of nodes between them
    max_graceful_termination_sec     = number #Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node
    scale_down_delay_after_add       = string #How long after the scale up of AKS nodes the scale down evaluation resumes
    scale_down_delay_after_delete    = string #How long after node deletion that scale down evaluation resumes
    scale_down_delay_after_failure   = string #How long after scale down failure that scale down evaluation resumes
    scan_interval                    = string #How often the AKS Cluster should be re-evaluated for scale up/down.
    scale_down_unneeded              = string # How long a node should be unneeded before it is eligible for scale down
    scale_down_unready               = string #How long an unready node should be unneeded before it is eligible for scale down
    scale_down_utilization_threshold = number #Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down
  })
  description = "TBD"
  default = {
    balance_similar_node_groups      = false
    max_graceful_termination_sec     = 600
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
  }
}

variable "rbac_enabled" {
  description = "Boolean to enable or disable role-based access control"
  type        = bool
  default     = true
}



variable "CLIENT_ID" {
  description = "The Client ID (appId) for the Service Principal used for the AKS deployment"
  type        = string
}

variable "CLIENT_SECRET" {
  description = "The Client Secret (password) for the Service Principal used for the AKS deployment"
  type        = string
}

variable "admin_username" {
  default     = "azureuser"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
  type        = string
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  default     = "PerGB2018"
  type        = string
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  default     = 30
  type        = number
}



variable "public_ssh_key" {
  description = "A custom ssh key to control access to the AKS cluster"
  default     = ""
  type        = string
}

variable "agent_pool_profile" {
  description = "An agent_pool_profile block, see terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#agent_pool_profile"
  type        = list(any)
  default = [{
    name            = "nodepool"
    count           = 1
    vm_size         = "standard_f2"
    os_type         = "Linux"
    agents_count    = 2
    os_disk_size_gb = 50
  }]
}

variable "default_node_pool" {
  description = "A default_node_pool block, see terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#default_node_pool"
  type = object({
    name                  = string       # (Required) The name which should be used for the default Kubernetes Node Pool
    vm_size               = string       #(Required) The size of the Virtual Machine, such as Standard_DS2_v2
    availability_zones    = list(string) #(Optional) A list of Availability Zones across which the Node Pool should be spread
    enable_node_public_ip = bool         #(Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false
    max_pods              = number       #Optional) The maximum number of pods that can run on each agent
    node_labels           = map(string)  #(Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool
    node_taints           = list(string) #(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool
    os_disk_size_gb       = number       #(Optional) The size of the OS Disk which should be used for each agent in the Node Pool
    type                  = string       #(Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets
    vnet_subnet_id        = string       #(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist
    node_count            = number       #(Optional) The initial number of nodes which should exist in this Node Pool
    orchestrator_version  = string       #(Optional) Version of Kubernetes used for the Agents
    tags                  = map(string)  #(Optional) A mapping of tags to assign to the Node Pool

  })
  default = {
    name                  = "nodepool"
    vm_size               = "standard_f2"
    availability_zones    = null #[]
    enable_node_public_ip = false
    max_pods              = null
    node_labels           = null #{}
    node_taints           = null #[]
    os_disk_size_gb       = null
    type                  = "VirtualMachineScaleSets"
    vnet_subnet_id        = null
    node_count            = null
    tags                  = null #{}
  }
}

variable "default_node_pool_scaling" {
  type = object({
    enable_auto_scaling = bool   #(Optional) Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false
    min_count           = number #(Required) The maximum number of nodes which should exist in this Node Pool
    max_count           = number #(Required) The minimum number of nodes which should exist in this Node Pool.
  })
  description = "(Optional) Should the Kubernetes Auto Scaler be enabled for the Node Pool?"
  default = {
    enable_auto_scaling = false
    min_count           = null
    max_count           = null
  }
}




# variable "aks_ignore_changes" {
#   description = "lifecycle.aks_ignore_changes to ignore"
#   type        = list(string)
#   default     = [""]
# }

variable "network_profile" {
  description = "Variables defining the AKS network profile config"
  type = object({
    network_plugin     = string
    network_policy     = string
    dns_service_ip     = string
    docker_bridge_cidr = string
    pod_cidr           = string
    service_cidr       = string
    load_balancer_sku  = string
  })
  default = {
    network_plugin     = "kubenet"
    network_policy     = ""
    dns_service_ip     = ""
    docker_bridge_cidr = ""
    pod_cidr           = ""
    service_cidr       = ""
    load_balancer_sku  = "Basic"
  }
}

variable "tags" {
  default     = {}
  description = "Any tags that should be present on resources"
  type        = map(string)
}







// Optional Variables
//**********************************************************************************************

variable "aks_suffix" {
  type        = string
  description = "(Optional) Suffix for AKS cluster name"
  default     = ""
}

variable "aks_prefix" {
  type        = string
  description = "(Optional) Prefix for AKS cluster name"
  default     = ""
}

variable "kubernetes_version" {
  type        = string
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster"
  default     = "1.15.11"
}

variable "role_based_access_control" {
  type = object({
    enabled = bool                    #(Required) Is Role Based Access Control Enabled
    azure_active_directory = object({ # (Optional) An azure_active_directory block
      client_app_id     = string
      server_app_id     = string
      server_app_secret = string
      tenant_id         = string
    })
  })
  description = "(Optional) A role_based_access_control block"
  default = {
    enabled = false
    azure_active_directory = {
      client_app_id     = null
      server_app_id     = null
      server_app_secret = null
      tenant_id         = null
    }
  }
}


variable "resource_tags" {
  type        = map(string)
  description = "(Optional) Tags for resources"
  default     = {}
}
variable "deployment_tags" {
  type        = map(string)
  description = "(Optional) Tags for deployment"
  default     = {}
}
variable "it_depends_on" {
  type        = any
  description = "(Optional) To define explicit dependencies if required"
  default     = null
}
//**********************************************************************************************


// Local Values
//**********************************************************************************************
locals {
  timeout_duration = "1h"
  aks_name         = "${var.aks_prefix}${var.aks_suffix}"
}
//**********************************************************************************************