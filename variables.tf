// Required Variables
//**********************************************************************************************
variable "resource_group_name" {
  type        = string
  description = "(Required) Specifies the Resource Group where the Managed Kubernetes Cluster should exist"
}

variable "location" {
  type        = string
  description = "(Required) The location where the Managed Kubernetes Cluster should be created"
}

variable "name" {
  type        = string
  description = "(Required) The name of the Managed Kubernetes Cluster to create"
}

variable "dns_prefix" {
  type        = string
  description = "(Required) DNS prefix specified when creating the managed cluster"
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
    node_count            = null
    orchestrator_version  = null
    tags                  = null #{}
  }
}

variable "vnet_subnet_id" {
  type        = string
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist"
  default     = null
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
//**********************************************************************************************



// Optional Variables
//**********************************************************************************************
### Addon Profile ###
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
# Azure policy is in public preview: https://docs.microsoft.com/en-gb/azure/governance/policy/concepts/policy-for-kubernetes
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
  description = "(Optional) Enable/Disable default Kubernetes dashboard"
  default = {
    enabled = true
  }
}
variable "addon_profile_oms_agent" {
  type = object({
    enabled                    = bool   #(Required) Is the OMS Agent Enabled?
    log_analytics_workspace_id = string #(Optional) The ID of the Log Analytics Workspace which the OMS Agent should send data to.
    #oms_agent_identity
  })
  description = "(Optional) Send AKS logs to OMS/Log Analytics Workspace"
  default = {
    enabled                    = false
    log_analytics_workspace_id = null
  }
}

# Security
variable "enable_pod_security_policy" {
  type        = bool
  description = "(Optional) Whether Pod Security Policies are enabled. Note that this also requires role based access control to be enabled"
  default     = false
}
variable "disk_encryption_set_id" {
  type        = string
  description = "(Optional) The ID of the Disk Encryption Set which should be used for the Nodes and Volumes"
  default     = null
}


# Authentication and Authorization
variable "rbac_enabled" {
  type        = bool
  description = "(Optional) Enable/Disable role based access control on AKS cluter"
  default     = false
}
variable "azure_active_directory" {
  type = map(object({
    managed                = bool         #(Optional)Is the Azure Active Directory integration Managed
    admin_group_object_ids = list(string) #(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster
    client_app_id          = string       #(Required) The Client ID of an Azure Active Directory Application
    server_app_id          = string       #(Required) The Server ID of an Azure Active Directory Application
    server_app_secret      = string       #(Required) The Server Secret of an Azure Active Directory Application
    tenant_id              = string       #(Optional) The Tenant ID used for Azure Active Directory Application
  }))
  description = "(Optional) Configure Kubernetes (RBAC) based on a user's identity or directory group membership in Azure AD"
  default     = {}
}
/* variable "role_based_access_control" {
  type = map(object({
    enabled = bool                          #(Required) Is Role Based Access Control Enabled
    azure_active_directory = object({       
      managed                = bool         #(Optional)Is the Azure Active Directory integration Managed
      admin_group_object_ids = list(string) #(Optional) A list of Object IDs of Azure Active Directory Groups which should have Admin Role on the Cluster
      client_app_id          = string       #(Required) The Client ID of an Azure Active Directory Application
      server_app_id          = string       #(Required) The Server ID of an Azure Active Directory Application
      server_app_secret      = string       #(Required) The Server Secret of an Azure Active Directory Application
      tenant_id              = string       #(Optional) The Tenant ID used for Azure Active Directory Application
    })
  }))
  description = "(Optional) A role_based_access_control block"
  default     = {}
} */
variable "csi_with_aadpod_id" {
  type        = bool
  description = "(Optional) Do you want to deploy CSI Driver with AAD Pod Identity AUthentication?"
  default     = false
}
/* variable "identity_type" {
  type        = string
  description = "(Optional) The type of identity used for the managed cluster"
  default     = "SystemAssigned"
} */
variable "identity" {
  type = map(object({
    type = string #(Required) The type of identity used for the managed cluster
  }))
  description = "(Optional) Managed Identity to interact with Azure APIs"
  default = {
    id1 = {
      type = "SystemAssigned"
    }
  }
}
variable "role_assignment_node_rg" {
  type = map(object({
    role_definition_id   = string #(Optional) The Scoped-ID of the Role Definition
    role_definition_name = string #(Optional) The name of a built-in Role. Changing this forces a new resource to be created
  }))
  description = "(Optional) Role assignment to AKS's Managed Identity over Node Resource Group"
  default = {
    manged_id_operator = {
      role_definition_id   = null
      role_definition_name = "Managed Identity Operator"

    },
    vm_contributor = {
      role_definition_id   = null
      role_definition_name = "Virtual Machine Contributor"
    }
  }
}
variable "role_assignment_others" {
  type = map(object({
    scope                = string #(Required) The scope at which the Role Assignment applies to
    role_definition_id   = string #(Optional) The Scoped-ID of the Role Definition
    role_definition_name = string #(Optional) The name of a built-in Role. Changing this forces a new resource to be created
  }))
  description = "(Optional) Role assignment to AKS's Managed Identity over Node Resource Group"
  default     = {}
}
variable "service_principal" {
  type = map(object({
    client_id     = string #(Required) The Client ID for the Service Principal
    client_secret = string #(Required) The Client Secret for the Service Principal.
  }))
  description = "(Optional) Service principle to interact with Azure APIs"
  default     = {}
}
variable "linux_profile" {
  type = map(object({
    admin_username = string #(Required) The Admin Username for the Cluster
    ssh_key = object({
      key_data = string #(Required) The Public SSH Key used to access the cluster
    })
  }))
  description = "(Optional) SSH authentication parameter values"
  default     = {}
}
variable "windows_profile" {
  type = map(object({
    admin_username = string #(Required) The Admin Username for Windows VMs
    admin_password = string #(Required) The Admin Password for Windows VMs.
  }))
  description = "(Optional) Windows Profile"
  default     = {}
}


# Networking
variable "network_profile" {
  type = map(object({
    network_plugin     = string #(Required) Network plugin to use for networking
    network_policy     = string #(Optional) Sets up network policy to be used with Azure CNI
    dns_service_ip     = string #(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)
    docker_bridge_cidr = string #(Optional) IP address (in CIDR notation) used as the Docker bridge IP address on nodes
    pod_cidr           = string #(Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet
    service_cidr       = string #(Optional) The Network Range used by the Kubernetes service
    outbound_type      = string #(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster
    load_balancer_sku  = string #(Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster
    #load_balancer_profile = object({})
  }))
  description = "(Optional) Variables defining the AKS network profile config"
  default     = {}
}
variable "private_cluster_enabled" {
  type        = bool
  description = "(Optional) Should this Kubernetes Cluster have it's API server only exposed on internal IP addresses?"
  default     = false
}
variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "(Optional) The IP ranges to whitelist for incoming traffic to the masters"
  default     = []
}

# Management
variable "kubernetes_version" {
  type        = string
  description = "(Optional) Version of Kubernetes specified when creating the AKS managed cluster"
  default     = "1.16.13"
}
variable "sku_tier" {
  type        = string
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster"
  default     = "Free"
}
variable "node_resource_group" {
  description = "(Optional) The name of the Resource Group where the Kubernetes Nodes should exist"
  default     = null
}
# Auto Scaler
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

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) Tags for the resources"
  default     = {}
}

variable "deployment_tags" {
  type        = map(string)
  description = "(Optional) Additional Tags for the deployment"
  default     = {}
}

variable "it_depends_on" {
  type        = any
  description = "(Optional) To define explicit dependencies if required"
  default     = null
}

variable "timeout" {
  type        = string
  description = "(Optional) Timeout"
  default     = "90m"
}


// Local Values
locals {
  timeout_duration = var.timeout
  aks_name         = "${var.aks_prefix}${var.name}${var.aks_suffix}"
}
//**********************************************************************************************