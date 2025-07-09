# vSphere Base Module
# This module creates the foundational vSphere resources for Tanzu Kubernetes Grid

# Input variables
variable "datacenter_id" {
  description = "vSphere datacenter ID"
  type        = string
}

variable "datastore_id" {
  description = "vSphere datastore ID"
  type        = string
}

variable "cluster_id" {
  description = "vSphere cluster ID"
  type        = string
}

variable "network_id" {
  description = "vSphere network ID"
  type        = string
}

variable "template_id" {
  description = "VM template ID"
  type        = string
}

variable "resource_pool_name" {
  description = "Name of the resource pool to create"
  type        = string
}

variable "vm_folder_name" {
  description = "Name of the VM folder to create"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Create resource pool for Tanzu clusters
resource "vsphere_resource_pool" "tanzu_resource_pool" {
  name                    = var.resource_pool_name
  parent_resource_pool_id = var.cluster_id
  
  cpu_share_level         = "normal"
  cpu_limit               = -1
  cpu_reservation         = 0
  cpu_expandable          = true
  
  memory_share_level      = "normal"
  memory_limit            = -1
  memory_reservation      = 0
  memory_expandable       = true
  
  tags = var.common_tags
}

# Create VM folder for Tanzu clusters
resource "vsphere_folder" "tanzu_vm_folder" {
  path          = var.vm_folder_name
  type          = "vm"
  datacenter_id = var.datacenter_id
  
  tags = var.common_tags
}

# Create custom attributes for Tanzu resources
resource "vsphere_custom_attribute" "tanzu_cluster_attribute" {
  name                = "tanzu-cluster"
  managed_object_type = "VirtualMachine"
}

resource "vsphere_custom_attribute" "tanzu_role_attribute" {
  name                = "tanzu-role"
  managed_object_type = "VirtualMachine"
}

resource "vsphere_custom_attribute" "tanzu_environment_attribute" {
  name                = "tanzu-environment"
  managed_object_type = "VirtualMachine"
}

# Create vSphere tags and categories for Tanzu
resource "vsphere_tag_category" "tanzu_cluster_category" {
  name               = "tanzu-cluster"
  description        = "Tanzu cluster identification"
  cardinality        = "SINGLE"
  associable_types   = ["VirtualMachine"]
}

resource "vsphere_tag_category" "tanzu_role_category" {
  name               = "tanzu-role"
  description        = "Tanzu node role identification"
  cardinality        = "SINGLE"
  associable_types   = ["VirtualMachine"]
}

resource "vsphere_tag_category" "tanzu_environment_category" {
  name               = "tanzu-environment"
  description        = "Tanzu environment identification"
  cardinality        = "SINGLE"
  associable_types   = ["VirtualMachine"]
}

# Create tags for management cluster
resource "vsphere_tag" "management_cluster_tag" {
  name        = "management"
  category_id = vsphere_tag_category.tanzu_cluster_category.id
  description = "Management cluster VMs"
}

# Create tags for development cluster
resource "vsphere_tag" "dev_cluster_tag" {
  name        = "development"
  category_id = vsphere_tag_category.tanzu_cluster_category.id
  description = "Development cluster VMs"
}

# Create tags for production cluster
resource "vsphere_tag" "prod_cluster_tag" {
  name        = "production"
  category_id = vsphere_tag_category.tanzu_cluster_category.id
  description = "Production cluster VMs"
}

# Create tags for node roles
resource "vsphere_tag" "control_plane_tag" {
  name        = "control-plane"
  category_id = vsphere_tag_category.tanzu_role_category.id
  description = "Control plane node VMs"
}

resource "vsphere_tag" "worker_tag" {
  name        = "worker"
  category_id = vsphere_tag_category.tanzu_role_category.id
  description = "Worker node VMs"
}

# Create tags for environments
resource "vsphere_tag" "dev_environment_tag" {
  name        = "dev"
  category_id = vsphere_tag_category.tanzu_environment_category.id
  description = "Development environment"
}

resource "vsphere_tag" "prod_environment_tag" {
  name        = "prod"
  category_id = vsphere_tag_category.tanzu_environment_category.id
  description = "Production environment"
}

resource "vsphere_tag" "mgmt_environment_tag" {
  name        = "mgmt"
  category_id = vsphere_tag_category.tanzu_environment_category.id
  description = "Management environment"
}

# Create DRS VM groups for anti-affinity
resource "vsphere_drs_vm_override" "tanzu_drs_override" {
  compute_cluster_id = var.cluster_id
  virtual_machine_id = var.template_id
  
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
}

# Data source to get cluster hosts for DRS rules
data "vsphere_host" "cluster_hosts" {
  count         = 3
  name          = "esxi-host-${count.index + 1}"
  datacenter_id = var.datacenter_id
}

# Create DRS anti-affinity rules for control plane nodes
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "control_plane_anti_affinity" {
  name                = "control-plane-anti-affinity"
  compute_cluster_id  = var.cluster_id
  virtual_machine_ids = [] # This will be populated by the cluster modules
  enabled             = true
  mandatory           = true
}

# Create DRS anti-affinity rules for worker nodes
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "worker_anti_affinity" {
  name                = "worker-anti-affinity"
  compute_cluster_id  = var.cluster_id
  virtual_machine_ids = [] # This will be populated by the cluster modules
  enabled             = true
  mandatory           = false
}
