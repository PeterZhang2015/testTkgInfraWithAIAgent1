# Main Terraform configuration for Tanzu Kubernetes Infrastructure
# This file orchestrates the deployment of the complete vSphere Tanzu setup

terraform {
  required_version = ">= 1.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the vSphere provider
provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_username
  password             = var.vsphere_password
  allow_unverified_ssl = var.allow_unverified_ssl
}

# Local values for common configuration
locals {
  common_tags = {
    Environment = var.environment
    Project     = "tanzu-kubernetes-infrastructure"
    ManagedBy   = "terraform"
  }
}

# Data sources for vSphere objects
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "resource_pool" {
  name                = var.vsphere_resource_pool
  datacenter_id       = data.vsphere_datacenter.datacenter.id
  parent_resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
}

# Module calls for different components
module "vsphere_base" {
  source = "./modules/vsphere-base"
  
  datacenter_id     = data.vsphere_datacenter.datacenter.id
  datastore_id      = data.vsphere_datastore.datastore.id
  network_id        = data.vsphere_network.network.id
  resource_pool_id  = data.vsphere_resource_pool.resource_pool.id
  
  environment = var.environment
  common_tags = local.common_tags
}

module "networking" {
  source = "./modules/networking"
  
  depends_on = [module.vsphere_base]
  
  datacenter_id = data.vsphere_datacenter.datacenter.id
  cluster_id    = data.vsphere_compute_cluster.cluster.id
  
  environment = var.environment
  common_tags = local.common_tags
}

module "storage" {
  source = "./modules/storage"
  
  depends_on = [module.vsphere_base]
  
  datacenter_id = data.vsphere_datacenter.datacenter.id
  datastore_id  = data.vsphere_datastore.datastore.id
  
  environment = var.environment
  common_tags = local.common_tags
}

module "security" {
  source = "./modules/security"
  
  depends_on = [module.vsphere_base, module.networking]
  
  datacenter_id = data.vsphere_datacenter.datacenter.id
  
  environment = var.environment
  common_tags = local.common_tags
}

# Environment-specific modules
module "management_environment" {
  source = "./environments/mgmt"
  
  depends_on = [module.vsphere_base, module.networking, module.storage, module.security]
  
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  
  environment = "mgmt"
  common_tags = local.common_tags
}

module "development_environment" {
  source = "./environments/dev"
  
  depends_on = [module.management_environment]
  
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  
  environment = "dev"
  common_tags = local.common_tags
}

module "production_environment" {
  source = "./environments/prod"
  
  depends_on = [module.management_environment]
  
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  network_id       = data.vsphere_network.network.id
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  
  environment = "prod"
  common_tags = local.common_tags
}
