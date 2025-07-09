# Variables for Tanzu Kubernetes Infrastructure Terraform configuration

# vSphere Connection Variables
variable "vsphere_server" {
  description = "vCenter server FQDN or IP address"
  type        = string
  sensitive   = true
}

variable "vsphere_username" {
  description = "vCenter username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vCenter password"
  type        = string
  sensitive   = true
}

variable "allow_unverified_ssl" {
  description = "Allow unverified SSL certificates"
  type        = bool
  default     = true
}

# vSphere Infrastructure Variables
variable "vsphere_datacenter" {
  description = "vSphere datacenter name"
  type        = string
}

variable "vsphere_cluster" {
  description = "vSphere cluster name"
  type        = string
}

variable "vsphere_datastore" {
  description = "vSphere datastore name"
  type        = string
}

variable "vsphere_network" {
  description = "vSphere network name"
  type        = string
}

variable "vsphere_resource_pool" {
  description = "vSphere resource pool name"
  type        = string
  default     = "Resources"
}

variable "vsphere_folder" {
  description = "vSphere VM folder"
  type        = string
  default     = "tanzu-kubernetes"
}

# Environment Configuration
variable "environment" {
  description = "Environment name (dev, prod, mgmt)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "prod", "mgmt"], var.environment)
    error_message = "Environment must be one of: dev, prod, mgmt."
  }
}

# Tanzu Configuration
variable "tanzu_version" {
  description = "Tanzu Kubernetes release version"
  type        = string
  default     = "v1.25.7+vmware.2-tkg.1"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.25.7+vmware.2"
}

# Management Cluster Configuration
variable "management_cluster_config" {
  description = "Management cluster configuration"
  type = object({
    name                 = string
    control_plane_count  = number
    worker_count         = number
    control_plane_cpu    = number
    control_plane_memory = number
    control_plane_disk   = number
    worker_cpu           = number
    worker_memory        = number
    worker_disk          = number
  })
  default = {
    name                 = "mgmt-cluster"
    control_plane_count  = 3
    worker_count         = 2
    control_plane_cpu    = 4
    control_plane_memory = 8192
    control_plane_disk   = 40
    worker_cpu           = 4
    worker_memory        = 8192
    worker_disk          = 40
  }
}

# Development Cluster Configuration
variable "dev_cluster_config" {
  description = "Development cluster configuration"
  type = object({
    name                 = string
    control_plane_count  = number
    worker_count         = number
    control_plane_cpu    = number
    control_plane_memory = number
    control_plane_disk   = number
    worker_cpu           = number
    worker_memory        = number
    worker_disk          = number
  })
  default = {
    name                 = "dev-cluster"
    control_plane_count  = 3
    worker_count         = 3
    control_plane_cpu    = 2
    control_plane_memory = 4096
    control_plane_disk   = 20
    worker_cpu           = 2
    worker_memory        = 4096
    worker_disk          = 20
  }
}

# Production Cluster Configuration
variable "prod_cluster_config" {
  description = "Production cluster configuration"
  type = object({
    name                 = string
    control_plane_count  = number
    worker_count         = number
    control_plane_cpu    = number
    control_plane_memory = number
    control_plane_disk   = number
    worker_cpu           = number
    worker_memory        = number
    worker_disk          = number
  })
  default = {
    name                 = "prod-cluster"
    control_plane_count  = 3
    worker_count         = 3
    control_plane_cpu    = 4
    control_plane_memory = 8192
    control_plane_disk   = 40
    worker_cpu           = 4
    worker_memory        = 8192
    worker_disk          = 40
  }
}

# Networking Configuration
variable "network_config" {
  description = "Network configuration for clusters"
  type = object({
    service_cidr   = string
    pod_cidr       = string
    service_domain = string
  })
  default = {
    service_cidr   = "10.96.0.0/12"
    pod_cidr       = "192.168.0.0/16"
    service_domain = "cluster.local"
  }
}

# Storage Configuration
variable "storage_config" {
  description = "Storage configuration"
  type = object({
    storage_class      = string
    volume_binding_mode = string
    reclaim_policy     = string
  })
  default = {
    storage_class       = "vsphere-csi"
    volume_binding_mode = "WaitForFirstConsumer"
    reclaim_policy      = "Delete"
  }
}

# Security Configuration
variable "security_config" {
  description = "Security configuration"
  type = object({
    enable_pod_security_standards = bool
    enable_network_policies      = bool
    enable_rbac                  = bool
    enable_admission_controllers = bool
  })
  default = {
    enable_pod_security_standards = true
    enable_network_policies      = true
    enable_rbac                  = true
    enable_admission_controllers = true
  }
}

# Monitoring Configuration
variable "monitoring_config" {
  description = "Monitoring configuration"
  type = object({
    enable_prometheus = bool
    enable_grafana   = bool
    enable_alerting  = bool
    retention_days   = number
  })
  default = {
    enable_prometheus = true
    enable_grafana   = true
    enable_alerting  = true
    retention_days   = 30
  }
}

# GitOps Configuration
variable "gitops_config" {
  description = "GitOps configuration"
  type = object({
    enable_argocd = bool
    enable_flux   = bool
    git_repo_url  = string
    git_branch    = string
  })
  default = {
    enable_argocd = true
    enable_flux   = false
    git_repo_url  = "https://github.com/PeterZhang2015/testTkgInfraWithAIAgent1.git"
    git_branch    = "master"
  }
}

# Backup Configuration
variable "backup_config" {
  description = "Backup configuration"
  type = object({
    enable_velero    = bool
    enable_etcd_backup = bool
    backup_schedule    = string
    retention_days     = number
  })
  default = {
    enable_velero      = true
    enable_etcd_backup = true
    backup_schedule    = "0 2 * * *"
    retention_days     = 30
  }
}

# Additional Tags
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
