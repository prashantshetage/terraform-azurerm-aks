// Fetch the ID of AKS Nodes Resource Group
data "azurerm_resource_group" "aks_node_rg" {
  name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}

// Role assignment for AKS Kubelet's Identity over the AKS Node Resource Group
resource "azurerm_role_assignment" "node_rg" {
  for_each             = var.service_principal == null && var.csi_with_aadpod_id ? var.role_assignment_node_rg : {}
  scope                = data.azurerm_resource_group.aks_node_rg.id
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id #azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].user_assigned_identity_id
  role_definition_name = each.value.role_definition_name
  role_definition_id   = each.value.role_definition_id
}

// Role assignment for AKS Kubelet's Identity over the Managed identity Resource Group. This will be used for AAD Pod Id authentication is required
resource "azurerm_role_assignment" "managed_id_rg" {
  count                = var.service_principal == null && var.csi_with_aadpod_id ? 1 : 0
  scope                = var.managed_id_resource_group
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "Managed Identity Operator"
  role_definition_id   = null
}

// Role Assignment for AKS Kubelet's Identity to pull images from ACR
resource "azurerm_role_assignment" "kubelet_acrpull" {
  count                = var.service_principal == null && var.integrate_acr ? 1 : 0
  scope                = var.acr_id
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  role_definition_id   = null
}

// Additional role assignments for AKS Kubelet's identity
resource "azurerm_role_assignment" "others" {
  for_each             = var.service_principal == null && var.csi_with_aadpod_id ? var.role_assignment_others : {}
  scope                = each.value.scope
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = each.value.role_definition_name
  role_definition_id   = each.value.role_definition_id
}

// Role Assignment to SPN for ACR Image Pull
resource "azurerm_role_assignment" "spn_acrpull" {
  count                            = var.service_principal != null && var.integrate_acr ? 1 : 0
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = var.service_principal.client_id
  skip_service_principal_aad_check = var.skip_service_principal_aad_check

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}