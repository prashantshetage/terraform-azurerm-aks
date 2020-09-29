// Fetch the ID of AKS Nodes Resource Group
data "azurerm_resource_group" "aks_node_rg" {
  name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}


// Role assignment for AKS Managed Identity over the AKS Node Resource Group
resource "azurerm_role_assignment" "role_assignment_node_rg" {
  for_each             = var.service_principal == null && var.csi_with_aadpod_id ? var.role_assignment_node_rg : {}
  scope                = data.azurerm_resource_group.aks_node_rg.id
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id #azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].user_assigned_identity_id
  role_definition_name = each.value.role_definition_name
  role_definition_id   = each.value.role_definition_id
}


// Additional role assignments for AKS Managed identity
resource "azurerm_role_assignment" "role_assignment_others" {
  for_each             = var.service_principal == null && var.csi_with_aadpod_id ? var.role_assignment_others : {}
  scope                = each.value.scope
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id #azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].user_assigned_identity_id
  role_definition_name = each.value.role_definition_name
  role_definition_id   = each.value.role_definition_id
}


// Role assignment for AKS Managed Identity over the Managed identity Resource Group
resource "azurerm_role_assignment" "role_assignment_managed_id" {
  count                = var.service_principal == null && var.csi_with_aadpod_id && var.managed_id_resource_group != null ? 1 : 0
  scope                = var.managed_id_resource_group
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "Managed Identity Operator"
  role_definition_id   = null
}
