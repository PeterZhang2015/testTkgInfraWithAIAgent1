# vSphere Base Infrastructure Module
# This module sets up the foundational vSphere infrastructure components

terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }
}

# Local values for resource naming
locals {
  name_prefix = "${var.environment}-tanzu"
  
  vm_template_configs = {
    kubernetes = {
      name         = "${local.name_prefix}-k8s-template"
      description  = "Kubernetes node template for ${var.environment} environment"
      cpu_count    = 2
      memory_mb    = 4096
      disk_size_gb = 20
      guest_id     = "ubuntu64Guest"
    }
    
    ubuntu = {
      name         = "${local.name_prefix}-ubuntu-template"
      description  = "Ubuntu base template for ${var.environment} environment"
      cpu_count    = 1
      memory_mb    = 2048
      disk_size_gb = 20
      guest_id     = "ubuntu64Guest"
    }
  }
}

# Create VM folder for organizing Tanzu resources
resource "vsphere_folder" "tanzu_folder" {
  path          = "${var.environment}-tanzu-infrastructure"
  type          = "vm"
  datacenter_id = var.datacenter_id
  
  tags = var.common_tags
}

# Create resource pool for Tanzu workloads
resource "vsphere_resource_pool" "tanzu_resource_pool" {
  name                    = "${local.name_prefix}-resource-pool"
  parent_resource_pool_id = var.resource_pool_id
  
  # CPU configuration
  cpu_expandable   = true
  cpu_limit        = -1
  cpu_reservation  = 0
  cpu_share_level  = "normal"
  
  # Memory configuration
  memory_expandable   = true
  memory_limit        = -1
  memory_reservation  = 0
  memory_share_level  = "normal"
  
  tags = var.common_tags
}

# Create custom attributes for Tanzu resources
resource "vsphere_custom_attribute" "tanzu_cluster_name" {
  name                = "tanzu-cluster-name"
  managed_object_type = "VirtualMachine"
}

resource "vsphere_custom_attribute" "tanzu_cluster_role" {
  name                = "tanzu-cluster-role"
  managed_object_type = "VirtualMachine"
}

resource "vsphere_custom_attribute" "tanzu_environment" {
  name                = "tanzu-environment"
  managed_object_type = "VirtualMachine"
}

# Create VM templates for Kubernetes nodes (placeholder - actual template creation would be done via Packer)
# This is a data source reference to templates that would be created separately
data "vsphere_virtual_machine" "kubernetes_template" {
  count         = var.create_templates ? 1 : 0
  name          = "kubernetes-${var.kubernetes_version}-template"
  datacenter_id = var.datacenter_id
}

# Create DRS rules for HA deployment
resource "vsphere_drs_vm_override" "tanzu_drs_override" {
  count                = var.enable_drs ? 1 : 0
  compute_cluster_id   = var.cluster_id
  virtual_machine_id   = data.vsphere_virtual_machine.kubernetes_template[0].id
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
}

# Create vSphere tags for resource management
resource "vsphere_tag_category" "tanzu_environment" {
  name               = "tanzu-environment"
  description        = "Tanzu environment classification"
  cardinality        = "SINGLE"
  
  associable_types = [
    "VirtualMachine",
    "ResourcePool",
    "Folder"
  ]
}

resource "vsphere_tag" "environment_tag" {
  name        = var.environment
  category_id = vsphere_tag_category.tanzu_environment.id
  description = "Environment tag for ${var.environment}"
}

resource "vsphere_tag_category" "tanzu_cluster_role" {
  name               = "tanzu-cluster-role"
  description        = "Tanzu cluster role classification"
  cardinality        = "SINGLE"
  
  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "control_plane_tag" {
  name        = "control-plane"
  category_id = vsphere_tag_category.tanzu_cluster_role.id
  description = "Control plane node tag"
}

resource "vsphere_tag" "worker_tag" {
  name        = "worker"
  category_id = vsphere_tag_category.tanzu_cluster_role.id
  description = "Worker node tag"
}

# Create VM storage policies if needed
resource "vsphere_storage_drs_vm_override" "tanzu_storage_drs" {
  count               = var.enable_storage_drs ? 1 : 0
  datastore_cluster_id = var.datastore_cluster_id
  virtual_machine_id   = data.vsphere_virtual_machine.kubernetes_template[0].id
  sdrs_enabled         = true
  sdrs_automation_level = "fullyAutomated"
  sdrs_intra_vm_affinity = true
}

# Output important resource IDs and information
output "folder_id" {
  description = "VM folder ID for Tanzu resources"
  value       = vsphere_folder.tanzu_folder.id
}

output "resource_pool_id" {
  description = "Resource pool ID for Tanzu workloads"
  value       = vsphere_resource_pool.tanzu_resource_pool.id
}

output "custom_attributes" {
  description = "Custom attributes for Tanzu resources"
  value = {
    cluster_name = vsphere_custom_attribute.tanzu_cluster_name.id
    cluster_role = vsphere_custom_attribute.tanzu_cluster_role.id
    environment  = vsphere_custom_attribute.tanzu_environment.id
  }
}

output "tags" {
  description = "vSphere tags for resource management"
  value = {
    environment_category = vsphere_tag_category.tanzu_environment.id
    environment_tag      = vsphere_tag.environment_tag.id
    role_category        = vsphere_tag_category.tanzu_cluster_role.id
    control_plane_tag    = vsphere_tag.control_plane_tag.id
    worker_tag          = vsphere_tag.worker_tag.id
  }
}

output "template_info" {
  description = "VM template information"
  value = var.create_templates ? {
    kubernetes_template_id = data.vsphere_virtual_machine.kubernetes_template[0].id
    kubernetes_template_name = data.vsphere_virtual_machine.kubernetes_template[0].name
  } : {}
}
