# Outputs for vSphere Tanzu Kubernetes Infrastructure
# These outputs provide important information about the deployed infrastructure

# vSphere Infrastructure Outputs
output "vsphere_datacenter_id" {
  description = "ID of the vSphere datacenter"
  value       = data.vsphere_datacenter.datacenter.id
}

output "vsphere_cluster_id" {
  description = "ID of the vSphere cluster"
  value       = data.vsphere_compute_cluster.cluster.id
}

output "vsphere_datastore_id" {
  description = "ID of the vSphere datastore"
  value       = data.vsphere_datastore.datastore.id
}

output "vsphere_network_id" {
  description = "ID of the vSphere network"
  value       = data.vsphere_network.network.id
}

# Base Infrastructure Outputs
output "resource_pool_id" {
  description = "ID of the created resource pool"
  value       = module.vsphere_base.resource_pool_id
}

output "vm_folder_id" {
  description = "ID of the created VM folder"
  value       = module.vsphere_base.vm_folder_id
}

# Management Cluster Outputs
output "management_cluster_name" {
  description = "Name of the management cluster"
  value       = module.management_cluster.cluster_name
}

output "management_cluster_endpoint" {
  description = "API endpoint of the management cluster"
  value       = module.management_cluster.cluster_endpoint
  sensitive   = true
}

output "management_cluster_ca_certificate" {
  description = "CA certificate of the management cluster"
  value       = module.management_cluster.cluster_ca_certificate
  sensitive   = true
}

output "management_cluster_status" {
  description = "Status of the management cluster"
  value       = module.management_cluster.cluster_status
}

# Development Cluster Outputs
output "dev_cluster_name" {
  description = "Name of the development cluster"
  value       = module.dev_cluster.cluster_name
}

output "dev_cluster_endpoint" {
  description = "API endpoint of the development cluster"
  value       = module.dev_cluster.cluster_endpoint
  sensitive   = true
}

output "dev_cluster_ca_certificate" {
  description = "CA certificate of the development cluster"
  value       = module.dev_cluster.cluster_ca_certificate
  sensitive   = true
}

output "dev_cluster_status" {
  description = "Status of the development cluster"
  value       = module.dev_cluster.cluster_status
}

# Production Cluster Outputs
output "prod_cluster_name" {
  description = "Name of the production cluster"
  value       = module.prod_cluster.cluster_name
}

output "prod_cluster_endpoint" {
  description = "API endpoint of the production cluster"
  value       = module.prod_cluster.cluster_endpoint
  sensitive   = true
}

output "prod_cluster_ca_certificate" {
  description = "CA certificate of the production cluster"
  value       = module.prod_cluster.cluster_ca_certificate
  sensitive   = true
}

output "prod_cluster_status" {
  description = "Status of the production cluster"
  value       = module.prod_cluster.cluster_status
}

# Networking Outputs
output "network_configuration" {
  description = "Network configuration details"
  value = {
    cluster_cidr = var.network_config.cluster_cidr
    service_cidr = var.network_config.service_cidr
    pod_cidr     = var.network_config.pod_cidr
    dns_servers  = var.network_config.dns_servers
    load_balancer_pool = {
      start = var.network_config.load_balancer_config.ip_pool_start
      end   = var.network_config.load_balancer_config.ip_pool_end
    }
  }
}

# Storage Outputs
output "storage_configuration" {
  description = "Storage configuration details"
  value = {
    storage_class     = var.storage_config.storage_class
    storage_policy    = var.storage_config.storage_policy
    default_disk_size = var.storage_config.default_disk_size
    reclaim_policy    = var.storage_config.reclaim_policy
  }
}

# Security Outputs
output "security_configuration" {
  description = "Security configuration status"
  value = {
    pod_security_standards_enabled = var.security_config.enable_pod_security_standards
    network_policies_enabled       = var.security_config.enable_network_policies
    admission_controllers_enabled  = var.security_config.enable_admission_controllers
    image_registry_url            = var.security_config.image_registry_config.registry_url
  }
}

# Kubeconfig Access Information
output "kubeconfig_commands" {
  description = "Commands to get kubeconfig for each cluster"
  value = {
    management_cluster = "tanzu management-cluster kubeconfig get ${module.management_cluster.cluster_name} --admin"
    dev_cluster       = "tanzu cluster kubeconfig get ${module.dev_cluster.cluster_name} --admin"
    prod_cluster      = "tanzu cluster kubeconfig get ${module.prod_cluster.cluster_name} --admin"
  }
}

# Cluster Information Summary
output "cluster_summary" {
  description = "Summary of all deployed clusters"
  value = {
    management_cluster = {
      name               = module.management_cluster.cluster_name
      kubernetes_version = var.management_cluster_config.kubernetes_version
      control_plane_count = var.management_cluster_config.control_plane_count
      worker_count       = var.management_cluster_config.worker_count
      status            = module.management_cluster.cluster_status
    }
    dev_cluster = {
      name               = module.dev_cluster.cluster_name
      kubernetes_version = var.dev_cluster_config.kubernetes_version
      control_plane_count = var.dev_cluster_config.control_plane_count
      worker_count       = var.dev_cluster_config.worker_count
      status            = module.dev_cluster.cluster_status
    }
    prod_cluster = {
      name               = module.prod_cluster.cluster_name
      kubernetes_version = var.prod_cluster_config.kubernetes_version
      control_plane_count = var.prod_cluster_config.control_plane_count
      worker_count       = var.prod_cluster_config.worker_count
      status            = module.prod_cluster.cluster_status
    }
  }
}

# Infrastructure Tags
output "applied_tags" {
  description = "Tags applied to all resources"
  value       = var.common_tags
}
