# Development Environment Configuration
# This configuration sets up the development environment for TKG clusters

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

# Development cluster configuration
module "dev_cluster" {
  source = "../../modules/vsphere-base"
  
  # Environment specific configuration
  environment = "dev"
  cluster_name = "dev-cluster"
  
  # vSphere configuration
  vsphere_datacenter    = data.vsphere_datacenter.dc.name
  vsphere_datastore     = data.vsphere_datastore.datastore.name
  vsphere_resource_pool = data.vsphere_resource_pool.pool.name
  vsphere_network       = data.vsphere_network.network.name
  
  # Cluster sizing for dev
  control_plane_count = 3
  worker_count        = 3
  
  # Resource specifications for dev
  control_plane_cpu    = 4
  control_plane_memory = 8192
  control_plane_disk   = 40
  
  worker_cpu    = 4
  worker_memory = 8192
  worker_disk   = 40
  
  # Dev-specific tags
  tags = {
    Environment = "development"
    Project     = "tanzu-k8s"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}

# Networking configuration for dev
module "dev_networking" {
  source = "../../modules/networking"
  
  environment = "dev"
  cluster_name = "dev-cluster"
  
  # Network configuration
  network_cidr = "10.0.1.0/24"
  service_cidr = "10.96.0.0/12"
  pod_cidr     = "192.168.0.0/16"
  
  # Load balancer configuration
  lb_ip_range = "10.0.1.100-10.0.1.120"
  
  depends_on = [module.dev_cluster]
}

# Storage configuration for dev
module "dev_storage" {
  source = "../../modules/storage"
  
  environment = "dev"
  cluster_name = "dev-cluster"
  
  # Storage classes
  storage_classes = [
    {
      name = "fast"
      datastore = var.vsphere_datastore
      policy = "thin"
    },
    {
      name = "standard"
      datastore = var.vsphere_datastore
      policy = "thick"
    }
  ]
  
  depends_on = [module.dev_cluster]
}

# Security configuration for dev
module "dev_security" {
  source = "../../modules/security"
  
  environment = "dev"
  cluster_name = "dev-cluster"
  
  # Security policies
  pod_security_standard = "restricted"
  network_policy_enabled = true
  
  # RBAC configuration
  rbac_groups = [
    {
      name = "dev-admins"
      role = "cluster-admin"
    },
    {
      name = "dev-users"
      role = "edit"
    }
  ]
  
  depends_on = [module.dev_cluster]
}
