# vSphere Base Infrastructure Module
# This module provides foundational vSphere infrastructure components

terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4"
    }
  }
}

# Variables
variable "datacenter_id" {
  description = "vSphere datacenter ID"
  type        = string
}

variable "datastore_id" {
  description = "vSphere datastore ID"
  type        = string
}

variable "resource_pool_id" {
  description = "vSphere resource pool ID"
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

variable "vm_folder_id" {
  description = "VM folder ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# Data sources for additional vSphere resources
data "vsphere_host" "esxi_hosts" {
  count         = 3
  name          = "esxi-host-${count.index + 1}.local"
  datacenter_id = var.datacenter_id
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  count         = 1
  name          = "datastore-cluster-1"
  datacenter_id = var.datacenter_id
}

# Storage policy for vSAN
data "vsphere_storage_policy" "vsan_policy" {
  name = "vSAN Default Storage Policy"
}

# Resource pools for different tiers
resource "vsphere_resource_pool" "management_pool" {
  name                    = "management-pool"
  parent_resource_pool_id = var.resource_pool_id
  
  cpu_share_level      = "normal"
  cpu_limit            = -1
  cpu_reservation      = 0
  cpu_expandable       = true
  
  memory_share_level   = "normal"
  memory_limit         = -1
  memory_reservation   = 0
  memory_expandable    = true
  
  tags = var.common_tags
}

resource "vsphere_resource_pool" "workload_pool" {
  name                    = "workload-pool"
  parent_resource_pool_id = var.resource_pool_id
  
  cpu_share_level      = "normal"
  cpu_limit            = -1
  cpu_reservation      = 0
  cpu_expandable       = true
  
  memory_share_level   = "normal"
  memory_limit         = -1
  memory_reservation   = 0
  memory_expandable    = true
  
  tags = var.common_tags
}

# DRS rules for anti-affinity
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "control_plane_anti_affinity" {
  count               = 1
  name                = "control-plane-anti-affinity"
  compute_cluster_id  = data.vsphere_compute_cluster.cluster.id
  virtual_machine_ids = []
  
  depends_on = [vsphere_resource_pool.management_pool]
}

# vSphere distributed switch (if available)
data "vsphere_distributed_virtual_switch" "dvs" {
  count         = 1
  name          = "dvs-switch-1"
  datacenter_id = var.datacenter_id
}

# Port groups for network segmentation
resource "vsphere_distributed_port_group" "management_pg" {
  count                           = 1
  name                           = "management-portgroup"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs[0].id
  
  vlan_id = 100
  
  active_uplinks  = ["uplink1", "uplink2"]
  standby_uplinks = ["uplink3", "uplink4"]
  
  allow_promiscuous      = false
  allow_forged_transmits = false
  allow_mac_changes      = false
  
  depends_on = [data.vsphere_distributed_virtual_switch.dvs]
}

resource "vsphere_distributed_port_group" "workload_pg" {
  count                           = 1
  name                           = "workload-portgroup"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs[0].id
  
  vlan_id = 200
  
  active_uplinks  = ["uplink1", "uplink2"]
  standby_uplinks = ["uplink3", "uplink4"]
  
  allow_promiscuous      = false
  allow_forged_transmits = false
  allow_mac_changes      = false
  
  depends_on = [data.vsphere_distributed_virtual_switch.dvs]
}

# VM folders for organization
resource "vsphere_folder" "management_folder" {
  path          = "management-vms"
  type          = "vm"
  datacenter_id = var.datacenter_id
  
  tags = var.common_tags
}

resource "vsphere_folder" "workload_folder" {
  path          = "workload-vms"
  type          = "vm"
  datacenter_id = var.datacenter_id
  
  tags = var.common_tags
}

# Custom attributes for VM categorization
resource "vsphere_custom_attribute" "environment_attr" {
  name                = "Environment"
  managed_object_type = "VirtualMachine"
}

resource "vsphere_custom_attribute" "cluster_role_attr" {
  name                = "ClusterRole"
  managed_object_type = "VirtualMachine"
}

resource "vsphere_custom_attribute" "backup_policy_attr" {
  name                = "BackupPolicy"
  managed_object_type = "VirtualMachine"
}

# VM storage policy
resource "vsphere_storage_policy" "k8s_storage_policy" {
  name        = "k8s-storage-policy"
  description = "Storage policy for Kubernetes nodes"
  
  policy_rule {
    type = "vsan"
    
    vsan_rule {
      failures_to_tolerate = 1
      stripe_width        = 1
      force_provisioning  = false
      object_space_reservation = 0
    }
  }
}

# Output values
output "infrastructure_info" {
  description = "vSphere base infrastructure information"
  value = {
    datacenter_id           = var.datacenter_id
    management_pool_id      = vsphere_resource_pool.management_pool.id
    workload_pool_id        = vsphere_resource_pool.workload_pool.id
    management_folder_id    = vsphere_folder.management_folder.id
    workload_folder_id      = vsphere_folder.workload_folder.id
    storage_policy_id       = vsphere_storage_policy.k8s_storage_policy.id
    environment_attr_id     = vsphere_custom_attribute.environment_attr.id
    cluster_role_attr_id    = vsphere_custom_attribute.cluster_role_attr.id
    backup_policy_attr_id   = vsphere_custom_attribute.backup_policy_attr.id
  }
}

output "network_info" {
  description = "Network configuration information"
  value = {
    management_portgroup_id = try(vsphere_distributed_port_group.management_pg[0].id, null)
    workload_portgroup_id   = try(vsphere_distributed_port_group.workload_pg[0].id, null)
  }
}

output "resource_pools" {
  description = "Resource pool information"
  value = {
    management = {
      id   = vsphere_resource_pool.management_pool.id
      name = vsphere_resource_pool.management_pool.name
    }
    workload = {
      id   = vsphere_resource_pool.workload_pool.id
      name = vsphere_resource_pool.workload_pool.name
    }
  }
}

# Data source for compute cluster (needed for DRS rules)
data "vsphere_compute_cluster" "cluster" {
  name          = "cluster-1"
  datacenter_id = var.datacenter_id
}
