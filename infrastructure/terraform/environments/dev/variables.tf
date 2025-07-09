# Development Environment Variables

# vSphere Configuration
variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server FQDN or IP"
  type        = string
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter name"
  type        = string
  default     = "Datacenter"
}

variable "vsphere_datastore" {
  description = "vSphere datastore name for dev environment"
  type        = string
  default     = "datastore1"
}

variable "vsphere_resource_pool" {
  description = "vSphere resource pool for dev environment"
  type        = string
  default     = "dev-pool"
}

variable "vsphere_network" {
  description = "vSphere network name for dev environment"
  type        = string
  default     = "VM Network"
}

# Development Cluster Configuration
variable "dev_cluster_name" {
  description = "Name of the development cluster"
  type        = string
  default     = "dev-cluster"
}

variable "dev_kubernetes_version" {
  description = "Kubernetes version for dev cluster"
  type        = string
  default     = "v1.26.5"
}

# Node Configuration
variable "dev_control_plane_count" {
  description = "Number of control plane nodes for dev"
  type        = number
  default     = 3
}

variable "dev_worker_count" {
  description = "Number of worker nodes for dev"
  type        = number
  default     = 3
}

# Resource Specifications
variable "dev_control_plane_cpu" {
  description = "CPU cores for dev control plane nodes"
  type        = number
  default     = 4
}

variable "dev_control_plane_memory" {
  description = "Memory in MB for dev control plane nodes"
  type        = number
  default     = 8192
}

variable "dev_control_plane_disk" {
  description = "Disk size in GB for dev control plane nodes"
  type        = number
  default     = 40
}

variable "dev_worker_cpu" {
  description = "CPU cores for dev worker nodes"
  type        = number
  default     = 4
}

variable "dev_worker_memory" {
  description = "Memory in MB for dev worker nodes"
  type        = number
  default     = 8192
}

variable "dev_worker_disk" {
  description = "Disk size in GB for dev worker nodes"
  type        = number
  default     = 40
}

# Networking Configuration
variable "dev_network_cidr" {
  description = "CIDR block for dev cluster network"
  type        = string
  default     = "10.0.1.0/24"
}

variable "dev_service_cidr" {
  description = "CIDR block for dev cluster services"
  type        = string
  default     = "10.96.0.0/12"
}

variable "dev_pod_cidr" {
  description = "CIDR block for dev cluster pods"
  type        = string
  default     = "192.168.0.0/16"
}

variable "dev_lb_ip_range" {
  description = "IP range for load balancer in dev"
  type        = string
  default     = "10.0.1.100-10.0.1.120"
}

# Tags
variable "dev_tags" {
  description = "Tags for dev environment resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "tanzu-k8s"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}

# Security Configuration
variable "dev_pod_security_standard" {
  description = "Pod security standard for dev cluster"
  type        = string
  default     = "restricted"
}

variable "dev_network_policy_enabled" {
  description = "Enable network policies for dev cluster"
  type        = bool
  default     = true
}

# Backup Configuration
variable "dev_backup_enabled" {
  description = "Enable backup for dev cluster"
  type        = bool
  default     = true
}

variable "dev_backup_schedule" {
  description = "Backup schedule for dev cluster"
  type        = string
  default     = "0 2 * * *"
}

# Monitoring Configuration
variable "dev_monitoring_enabled" {
  description = "Enable monitoring for dev cluster"
  type        = bool
  default     = true
}

variable "dev_logging_enabled" {
  description = "Enable logging for dev cluster"
  type        = bool
  default     = true
}
