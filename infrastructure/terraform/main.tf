# VMware vSphere Tanzu Kubernetes Infrastructure
# Main Terraform configuration for deploying HA Tanzu infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Configure the VMware vSphere Provider
provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

# Data sources for existing vSphere resources
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

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Local values for common configurations
locals {
  common_tags = {
    Environment = var.environment
    Project     = "tanzu-k8s-infrastructure"
    Owner       = var.owner
    CreatedBy   = "terraform"
  }
}

# Resource groups and folders
resource "vsphere_folder" "vm_folder" {
  path          = var.vm_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Network configuration
module "networking" {
  source = "./modules/networking"
  
  datacenter_id = data.vsphere_datacenter.dc.id
  environment   = var.environment
  common_tags   = local.common_tags
}

# Storage configuration
module "storage" {
  source = "./modules/storage"
  
  datacenter_id = data.vsphere_datacenter.dc.id
  environment   = var.environment
  common_tags   = local.common_tags
}

# Security configuration
module "security" {
  source = "./modules/security"
  
  datacenter_id = data.vsphere_datacenter.dc.id
  environment   = var.environment
  common_tags   = local.common_tags
}

# vSphere base infrastructure
module "vsphere_base" {
  source = "./modules/vsphere-base"
  
  datacenter_id      = data.vsphere_datacenter.dc.id
  datastore_id       = data.vsphere_datastore.datastore.id
  resource_pool_id   = data.vsphere_resource_pool.pool.id
  network_id         = data.vsphere_network.network.id
  template_id        = data.vsphere_virtual_machine.template.id
  vm_folder_id       = vsphere_folder.vm_folder.id
  environment        = var.environment
  common_tags        = local.common_tags
}

# Management cluster environment
module "management_cluster" {
  source = "./environments/mgmt"
  
  datacenter_id      = data.vsphere_datacenter.dc.id
  datastore_id       = data.vsphere_datastore.datastore.id
  resource_pool_id   = data.vsphere_resource_pool.pool.id
  network_id         = data.vsphere_network.network.id
  template_id        = data.vsphere_virtual_machine.template.id
  vm_folder_id       = vsphere_folder.vm_folder.id
  environment        = "management"
  common_tags        = local.common_tags
}

# Development cluster environment
module "dev_cluster" {
  source = "./environments/dev"
  
  datacenter_id      = data.vsphere_datacenter.dc.id
  datastore_id       = data.vsphere_datastore.datastore.id
  resource_pool_id   = data.vsphere_resource_pool.pool.id
  network_id         = data.vsphere_network.network.id
  template_id        = data.vsphere_virtual_machine.template.id
  vm_folder_id       = vsphere_folder.vm_folder.id
  environment        = "development"
  common_tags        = local.common_tags
}

# Production cluster environment
module "prod_cluster" {
  source = "./environments/prod"
  
  datacenter_id      = data.vsphere_datacenter.dc.id
  datastore_id       = data.vsphere_datastore.datastore.id
  resource_pool_id   = data.vsphere_resource_pool.pool.id
  network_id         = data.vsphere_network.network.id
  template_id        = data.vsphere_virtual_machine.template.id
  vm_folder_id       = vsphere_folder.vm_folder.id
  environment        = "production"
  common_tags        = local.common_tags
}

# Outputs
output "management_cluster_info" {
  description = "Management cluster information"
  value       = module.management_cluster.cluster_info
}

output "dev_cluster_info" {
  description = "Development cluster information"
  value       = module.dev_cluster.cluster_info
}

output "prod_cluster_info" {
  description = "Production cluster information"
  value       = module.prod_cluster.cluster_info
}

output "vsphere_base_info" {
  description = "vSphere base infrastructure information"
  value       = module.vsphere_base.infrastructure_info
}
