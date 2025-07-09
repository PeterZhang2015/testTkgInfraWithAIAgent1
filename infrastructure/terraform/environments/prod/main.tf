# Production Environment Configuration
# This configuration sets up the production environment for TKG clusters

terraform {
  required_version = ">= 1.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
  }
}

# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  
  # If you have a self-signed certificate
  allow_unverified_ssl = true
}

# Data sources for vSphere objects
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Production cluster configuration
module "prod_cluster" {
  source = "../../modules/vsphere-base"
  
  # Environment specific configuration
  environment = "prod"
  cluster_name = "prod-cluster"
  
  # vSphere configuration
  vsphere_datacenter    = data.vsphere_datacenter.dc.name
  vsphere_datastore     = data.vsphere_datastore.datastore.name
  vsphere_resource_pool = data.vsphere_resource_pool.pool.name
  vsphere_network       = data.vsphere_network.network.name
  
  # Cluster sizing for production
  control_plane_count = 3
  worker_count        = 5
  
  # Resource specifications for production
  control_plane_cpu    = 8
  control_plane_memory = 16384
  control_plane_disk   = 100
  
  worker_cpu    = 8
  worker_memory = 16384
  worker_disk   = 100
  
  # Production-specific tags
  tags = {
    Environment = "production"
    Project     = "tanzu-k8s"
    Team        = "platform"
    CostCenter  = "operations"
    Criticality = "high"
  }
}

# Networking configuration for production
module "prod_networking" {
  source = "../../modules/networking"
  
  environment = "prod"
  cluster_name = "prod-cluster"
  
  # Network configuration
  network_cidr = "10.0.2.0/24"
  service_cidr = "10.96.0.0/12"
  pod_cidr     = "192.168.0.0/16"
  
  # Load balancer configuration
  lb_ip_range = "10.0.2.100-10.0.2.140"
  
  # High availability configuration
  ha_enabled = true
  
  depends_on = [module.prod_cluster]
}

# Storage configuration for production
module "prod_storage" {
  source = "../../modules/storage"
  
  environment = "prod"
  cluster_name = "prod-cluster"
  
  # Storage classes
  storage_classes = [
    {
      name = "fast-ssd"
      datastore = var.vsphere_datastore_ssd
      policy = "thin"
      reclaim_policy = "Retain"
    },
    {
      name = "standard"
      datastore = var.vsphere_datastore
      policy = "thick"
      reclaim_policy = "Retain"
    },
    {
      name = "backup"
      datastore = var.vsphere_datastore_backup
      policy = "thick"
      reclaim_policy = "Retain"
    }
  ]
  
  # Backup configuration
  backup_enabled = true
  backup_schedule = "0 1 * * *"
  
  depends_on = [module.prod_cluster]
}

# Security configuration for production
module "prod_security" {
  source = "../../modules/security"
  
  environment = "prod"
  cluster_name = "prod-cluster"
  
  # Security policies
  pod_security_standard = "restricted"
  network_policy_enabled = true
  admission_controller_enabled = true
  
  # RBAC configuration
  rbac_groups = [
    {
      name = "prod-admins"
      role = "cluster-admin"
    },
    {
      name = "prod-operators"
      role = "edit"
    },
    {
      name = "prod-viewers"
      role = "view"
    }
  ]
  
  # Security scanning
  vulnerability_scanning_enabled = true
  compliance_scanning_enabled = true
  
  depends_on = [module.prod_cluster]
}

# Monitoring configuration for production
module "prod_monitoring" {
  source = "../../modules/monitoring"
  
  environment = "prod"
  cluster_name = "prod-cluster"
  
  # Monitoring stack
  prometheus_enabled = true
  grafana_enabled = true
  alertmanager_enabled = true
  
  # Alerting configuration
  alert_receivers = [
    {
      name = "prod-alerts"
      email = "prod-alerts@company.com"
      slack_channel = "#prod-alerts"
    }
  ]
  
  depends_on = [module.prod_cluster]
}

# Backup configuration for production
module "prod_backup" {
  source = "../../modules/backup"
  
  environment = "prod"
  cluster_name = "prod-cluster"
  
  # Backup configuration
  velero_enabled = true
  etcd_backup_enabled = true
  
  # Backup schedule
  backup_schedule = "0 1 * * *"
  retention_days = 30
  
  # Backup storage
  backup_storage_location = var.backup_storage_location
  
  depends_on = [module.prod_cluster]
}
