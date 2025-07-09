# Outputs for Tanzu Kubernetes Infrastructure

# vSphere Infrastructure Outputs
output "vsphere_datacenter_id" {
  description = "vSphere datacenter ID"
  value       = data.vsphere_datacenter.datacenter.id
}

output "vsphere_datastore_id" {
  description = "vSphere datastore ID"
  value       = data.vsphere_datastore.datastore.id
}

output "vsphere_network_id" {
  description = "vSphere network ID"
  value       = data.vsphere_network.network.id
}

output "vsphere_resource_pool_id" {
  description = "vSphere resource pool ID"
  value       = data.vsphere_resource_pool.resource_pool.id
}

# Module Outputs
output "vsphere_base_info" {
  description = "vSphere base infrastructure information"
  value       = module.vsphere_base
}

output "networking_info" {
  description = "Networking configuration information"
  value       = module.networking
}

output "storage_info" {
  description = "Storage configuration information"
  value       = module.storage
}

output "security_info" {
  description = "Security configuration information"
  value       = module.security
}

# Management Environment Outputs
output "management_cluster_info" {
  description = "Management cluster information"
  value       = module.management_environment
  sensitive   = true
}

# Development Environment Outputs
output "development_cluster_info" {
  description = "Development cluster information"
  value       = module.development_environment
  sensitive   = true
}

# Production Environment Outputs
output "production_cluster_info" {
  description = "Production cluster information"
  value       = module.production_environment
  sensitive   = true
}

# Cluster Configuration Summary
output "cluster_summary" {
  description = "Summary of all cluster configurations"
  value = {
    management = {
      name                = var.management_cluster_config.name
      control_plane_count = var.management_cluster_config.control_plane_count
      worker_count        = var.management_cluster_config.worker_count
      environment         = "mgmt"
    }
    development = {
      name                = var.dev_cluster_config.name
      control_plane_count = var.dev_cluster_config.control_plane_count
      worker_count        = var.dev_cluster_config.worker_count
      environment         = "dev"
    }
    production = {
      name                = var.prod_cluster_config.name
      control_plane_count = var.prod_cluster_config.control_plane_count
      worker_count        = var.prod_cluster_config.worker_count
      environment         = "prod"
    }
  }
}

# Network Configuration Outputs
output "network_configuration" {
  description = "Network configuration details"
  value = {
    service_cidr   = var.network_config.service_cidr
    pod_cidr       = var.network_config.pod_cidr
    service_domain = var.network_config.service_domain
  }
}

# Storage Configuration Outputs
output "storage_configuration" {
  description = "Storage configuration details"
  value = {
    storage_class       = var.storage_config.storage_class
    volume_binding_mode = var.storage_config.volume_binding_mode
    reclaim_policy      = var.storage_config.reclaim_policy
  }
}

# Security Configuration Outputs
output "security_configuration" {
  description = "Security configuration details"
  value = {
    pod_security_standards = var.security_config.enable_pod_security_standards
    network_policies      = var.security_config.enable_network_policies
    rbac                  = var.security_config.enable_rbac
    admission_controllers = var.security_config.enable_admission_controllers
  }
}

# Monitoring Configuration Outputs
output "monitoring_configuration" {
  description = "Monitoring configuration details"
  value = {
    prometheus      = var.monitoring_config.enable_prometheus
    grafana        = var.monitoring_config.enable_grafana
    alerting       = var.monitoring_config.enable_alerting
    retention_days = var.monitoring_config.retention_days
  }
}

# GitOps Configuration Outputs
output "gitops_configuration" {
  description = "GitOps configuration details"
  value = {
    argocd     = var.gitops_config.enable_argocd
    flux       = var.gitops_config.enable_flux
    git_repo   = var.gitops_config.git_repo_url
    git_branch = var.gitops_config.git_branch
  }
}

# Backup Configuration Outputs
output "backup_configuration" {
  description = "Backup configuration details"
  value = {
    velero         = var.backup_config.enable_velero
    etcd_backup    = var.backup_config.enable_etcd_backup
    schedule       = var.backup_config.backup_schedule
    retention_days = var.backup_config.retention_days
  }
}

# Common Tags Output
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# Deployment Information
output "deployment_info" {
  description = "Deployment information and next steps"
  value = {
    terraform_version = ">=1.0"
    kubernetes_version = var.kubernetes_version
    tanzu_version     = var.tanzu_version
    environment       = var.environment
    deployment_date   = timestamp()
    next_steps = [
      "1. Verify vSphere infrastructure deployment",
      "2. Deploy Tanzu management cluster",
      "3. Deploy workload clusters (dev/prod)",
      "4. Configure GitOps with ArgoCD",
      "5. Set up monitoring and alerting",
      "6. Configure backup and disaster recovery"
    ]
  }
}
