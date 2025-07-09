# Development Environment Configuration
# This file contains the specific values for the development environment

# vSphere Configuration
vsphere_server     = "vcenter.example.com"
vsphere_datacenter = "Datacenter"
vsphere_datastore  = "datastore1"
vsphere_resource_pool = "dev-pool"
vsphere_network    = "VM Network"

# Development Cluster Configuration
dev_cluster_name = "dev-cluster"
dev_kubernetes_version = "v1.26.5"

# Node Configuration
dev_control_plane_count = 3
dev_worker_count = 3

# Resource Specifications for Development
dev_control_plane_cpu = 4
dev_control_plane_memory = 8192
dev_control_plane_disk = 40

dev_worker_cpu = 4
dev_worker_memory = 8192
dev_worker_disk = 40

# Networking Configuration
dev_network_cidr = "10.0.1.0/24"
dev_service_cidr = "10.96.0.0/12"
dev_pod_cidr = "192.168.0.0/16"
dev_lb_ip_range = "10.0.1.100-10.0.1.120"

# Tags
dev_tags = {
  Environment = "development"
  Project     = "tanzu-k8s"
  Team        = "platform"
  CostCenter  = "engineering"
  Owner       = "dev-team"
}

# Security Configuration
dev_pod_security_standard = "restricted"
dev_network_policy_enabled = true

# Backup Configuration
dev_backup_enabled = true
dev_backup_schedule = "0 2 * * *"

# Monitoring Configuration
dev_monitoring_enabled = true
dev_logging_enabled = true
