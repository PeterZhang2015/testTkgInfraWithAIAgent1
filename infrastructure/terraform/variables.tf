# VMware vSphere Variables
# Configuration variables for Tanzu Kubernetes infrastructure deployment

# vSphere Connection Variables
variable "vsphere_server" {
  description = "vSphere server FQDN or IP address"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+$", var.vsphere_server))
    error_message = "vSphere server must be a valid hostname or IP address."
  }
}

variable "vsphere_username" {
  description = "vSphere username for authentication"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password for authentication"
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
  default     = "Datacenter"
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

variable "vm_folder" {
  description = "VM folder path for organizing VMs"
  type        = string
  default     = "tanzu-k8s"
}

variable "vm_template" {
  description = "VM template name for cluster nodes"
  type        = string
  default     = "photon-3-kube-v1.23.8+vmware.2-template"
}

# Environment Configuration
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner/team responsible for the infrastructure"
  type        = string
  default     = "platform-team"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "tanzu-k8s-infrastructure"
}

# Network Configuration
variable "network_cidr" {
  description = "CIDR block for the network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "management_subnet" {
  description = "Subnet for management cluster"
  type        = string
  default     = "10.0.1.0/24"
}

variable "dev_subnet" {
  description = "Subnet for development cluster"
  type        = string
  default     = "10.0.2.0/24"
}

variable "prod_subnet" {
  description = "Subnet for production cluster"
  type        = string
  default     = "10.0.3.0/24"
}

# DNS Configuration
variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "domain_name" {
  description = "Domain name for the environment"
  type        = string
  default     = "local.domain"
}

# NTP Configuration
variable "ntp_servers" {
  description = "List of NTP servers"
  type        = list(string)
  default     = ["pool.ntp.org", "time.google.com"]
}

# Node Configuration
variable "node_count" {
  description = "Number of worker nodes per cluster"
  type        = number
  default     = 3
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "control_plane_count" {
  description = "Number of control plane nodes (must be odd)"
  type        = number
  default     = 3
  validation {
    condition     = var.control_plane_count % 2 == 1 && var.control_plane_count >= 1
    error_message = "Control plane count must be an odd number (1, 3, 5, etc.)."
  }
}

# VM Resource Configuration
variable "control_plane_vm_config" {
  description = "VM configuration for control plane nodes"
  type = object({
    cpu    = number
    memory = number
    disk   = number
  })
  default = {
    cpu    = 2
    memory = 8192
    disk   = 50
  }
}

variable "worker_vm_config" {
  description = "VM configuration for worker nodes"
  type = object({
    cpu    = number
    memory = number
    disk   = number
  })
  default = {
    cpu    = 4
    memory = 16384
    disk   = 100
  }
}

# Storage Configuration
variable "storage_policy" {
  description = "vSphere storage policy name"
  type        = string
  default     = "vSAN Default Storage Policy"
}

variable "enable_vsan" {
  description = "Enable vSAN storage"
  type        = bool
  default     = true
}

# Security Configuration
variable "enable_encryption" {
  description = "Enable VM encryption"
  type        = bool
  default     = true
}

variable "enable_secure_boot" {
  description = "Enable secure boot for VMs"
  type        = bool
  default     = true
}

# Kubernetes Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for the clusters"
  type        = string
  default     = "v1.23.8+vmware.2"
}

variable "pod_cidr" {
  description = "CIDR block for pod network"
  type        = string
  default     = "192.168.0.0/16"
}

variable "service_cidr" {
  description = "CIDR block for service network"
  type        = string
  default     = "10.96.0.0/12"
}

# Load Balancer Configuration
variable "enable_load_balancer" {
  description = "Enable load balancer for API server"
  type        = bool
  default     = true
}

variable "load_balancer_provider" {
  description = "Load balancer provider (metallb, nsx, etc.)"
  type        = string
  default     = "metallb"
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "monitoring_namespace" {
  description = "Namespace for monitoring components"
  type        = string
  default     = "monitoring"
}

# Logging Configuration
variable "enable_logging" {
  description = "Enable logging stack"
  type        = bool
  default     = true
}

variable "logging_namespace" {
  description = "Namespace for logging components"
  type        = string
  default     = "logging"
}

# Backup Configuration
variable "enable_backup" {
  description = "Enable backup solution"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Backup schedule (cron format)"
  type        = string
  default     = "0 2 * * *" # Daily at 2 AM
}

# GitOps Configuration
variable "enable_gitops" {
  description = "Enable GitOps with ArgoCD"
  type        = bool
  default     = true
}

variable "gitops_repo" {
  description = "GitOps repository URL"
  type        = string
  default     = ""
}

variable "gitops_branch" {
  description = "GitOps repository branch"
  type        = string
  default     = "main"
}

# Additional Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
