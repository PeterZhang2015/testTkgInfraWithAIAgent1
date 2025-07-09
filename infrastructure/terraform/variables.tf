# Variables for vSphere Tanzu Kubernetes Infrastructure
# Configure these values according to your environment

# vSphere Connection Configuration
variable "vsphere_server" {
  description = "vSphere server endpoint"
  type        = string
  sensitive   = true
}

variable "vsphere_username" {
  description = "vSphere username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "allow_unverified_ssl" {
  description = "Allow unverified SSL certificates"
  type        = bool
  default     = true
}

# vSphere Infrastructure Configuration
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

variable "vm_template" {
  description = "VM template name for Kubernetes nodes"
  type        = string
  default     = "ubuntu-20.04-kubernetes-v1.25.4"
}

variable "resource_pool_name" {
  description = "Resource pool name for Tanzu clusters"
  type        = string
  default     = "tanzu-resource-pool"
}

variable "vm_folder_name" {
  description = "VM folder name for Tanzu clusters"
  type        = string
  default     = "tanzu-vms"
}

# Common tags for all resources
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "tanzu-kubernetes"
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}

# Network Configuration
variable "network_config" {
  description = "Network configuration for Tanzu clusters"
  type = object({
    cluster_cidr          = string
    service_cidr          = string
    pod_cidr              = string
    dns_servers           = list(string)
    ntp_servers           = list(string)
    proxy_config          = optional(object({
      http_proxy  = string
      https_proxy = string
      no_proxy    = string
    }))
    load_balancer_config = object({
      ip_pool_start = string
      ip_pool_end   = string
    })
  })
  default = {
    cluster_cidr = "10.96.0.0/12"
    service_cidr = "10.96.0.0/12"
    pod_cidr     = "192.168.0.0/16"
    dns_servers  = ["8.8.8.8", "8.8.4.4"]
    ntp_servers  = ["pool.ntp.org"]
    load_balancer_config = {
      ip_pool_start = "10.10.1.100"
      ip_pool_end   = "10.10.1.200"
    }
  }
}

# Storage Configuration
variable "storage_config" {
  description = "Storage configuration for Tanzu clusters"
  type = object({
    storage_class     = string
    storage_policy    = string
    default_disk_size = string
    reclaim_policy    = string
  })
  default = {
    storage_class     = "tanzu-storage-class"
    storage_policy    = "tanzu-storage-policy"
    default_disk_size = "20Gi"
    reclaim_policy    = "Delete"
  }
}

# Security Configuration
variable "security_config" {
  description = "Security configuration for Tanzu clusters"
  type = object({
    enable_pod_security_standards = bool
    enable_network_policies       = bool
    enable_admission_controllers  = bool
    image_registry_config = object({
      registry_url = string
      username     = string
      password     = string
    })
  })
  default = {
    enable_pod_security_standards = true
    enable_network_policies       = true
    enable_admission_controllers  = true
    image_registry_config = {
      registry_url = "registry.tanzu.vmware.com"
      username     = ""
      password     = ""
    }
  }
}

# Management Cluster Configuration
variable "management_cluster_config" {
  description = "Management cluster configuration"
  type = object({
    cluster_name        = string
    kubernetes_version  = string
    control_plane_count = number
    worker_count        = number
    control_plane_vm_config = object({
      num_cpus          = number
      memory_mb         = number
      disk_size_gb      = number
    })
    worker_vm_config = object({
      num_cpus          = number
      memory_mb         = number
      disk_size_gb      = number
    })
    cluster_class = string
  })
  default = {
    cluster_name        = "mgmt-cluster"
    kubernetes_version  = "v1.25.4+vmware.1"
    control_plane_count = 3
    worker_count        = 2
    control_plane_vm_config = {
      num_cpus     = 4
      memory_mb    = 8192
      disk_size_gb = 40
    }
    worker_vm_config = {
      num_cpus     = 4
      memory_mb    = 8192
      disk_size_gb = 40
    }
    cluster_class = "tkg-vsphere-default-v1.0.0"
  }
}

# Development Cluster Configuration
variable "dev_cluster_config" {
  description = "Development cluster configuration"
  type = object({
    cluster_name        = string
    kubernetes_version  = string
    control_plane_count = number
    worker_count        = number
    control_plane_vm_config = object({
      num_cpus          = number
      memory_mb         = number
      disk_size_gb      = number
    })
    worker_vm_config = object({
      num_cpus          = number
      memory_mb         = number
      disk_size_gb      = number
    })
    cluster_class = string
  })
  default = {
    cluster_name        = "dev-cluster"
    kubernetes_version  = "v1.25.4+vmware.1"
    control_plane_count = 3
    worker_count        = 3
    control_plane_vm_config = {
      num_cpus     = 2
      memory_mb    = 4096
      disk_size_gb = 20
    }
    worker_vm_config = {
      num_cpus     = 4
      memory_mb    = 8192
      disk_size_gb = 40
    }
    cluster_class = "tkg-vsphere-default-v1.0.0"
  }
}

# Production Cluster Configuration
variable "prod_cluster_config" {
  description = "Production cluster configuration"
  type = object({
    cluster_name        = string
    kubernetes_version  = string
    control_plane_count = number
    worker_count        = number
    control_plane_vm_config = object({
      num_cpus          = number
      memory_mb         = number
      disk_size_gb      = number
    })
    worker_vm_config = object({
      num_cpus          = number
      memory_mb         = number
      disk_size_gb      = number
    })
    cluster_class = string
  })
  default = {
    cluster_name        = "prod-cluster"
    kubernetes_version  = "v1.25.4+vmware.1"
    control_plane_count = 3
    worker_count        = 3
    control_plane_vm_config = {
      num_cpus     = 4
      memory_mb    = 8192
      disk_size_gb = 40
    }
    worker_vm_config = {
      num_cpus     = 8
      memory_mb    = 16384
      disk_size_gb = 80
    }
    cluster_class = "tkg-vsphere-default-v1.0.0"
  }
}
