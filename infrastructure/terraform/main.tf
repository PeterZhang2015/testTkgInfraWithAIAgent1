# VMware vSphere Tanzu Kubernetes Infrastructure
# Main Terraform configuration for deploying HA Tanzu Kubernetes Grid

terraform {
  required_version = ">= 1.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure vSphere provider
provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

# Data sources for vSphere resources
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Module for vSphere base infrastructure
module "vsphere_base" {
  source = "./modules/vsphere-base"

  datacenter_id = data.vsphere_datacenter.datacenter.id
  datastore_id  = data.vsphere_datastore.datastore.id
  cluster_id    = data.vsphere_compute_cluster.cluster.id
  network_id    = data.vsphere_network.network.id
  template_id   = data.vsphere_virtual_machine.template.id

  resource_pool_name = var.resource_pool_name
  vm_folder_name     = var.vm_folder_name
  
  common_tags = var.common_tags
}

# Module for networking configuration
module "networking" {
  source = "./modules/networking"

  datacenter_id = data.vsphere_datacenter.datacenter.id
  cluster_id    = data.vsphere_compute_cluster.cluster.id
  
  network_config = var.network_config
  common_tags    = var.common_tags
}

# Module for storage configuration
module "storage" {
  source = "./modules/storage"

  datacenter_id = data.vsphere_datacenter.datacenter.id
  cluster_id    = data.vsphere_compute_cluster.cluster.id
  
  storage_config = var.storage_config
  common_tags    = var.common_tags
}

# Module for security configuration
module "security" {
  source = "./modules/security"

  datacenter_id = data.vsphere_datacenter.datacenter.id
  cluster_id    = data.vsphere_compute_cluster.cluster.id
  
  security_config = var.security_config
  common_tags     = var.common_tags
}

# Local values for common configuration
locals {
  common_vm_config = {
    datacenter_id = data.vsphere_datacenter.datacenter.id
    datastore_id  = data.vsphere_datastore.datastore.id
    cluster_id    = data.vsphere_compute_cluster.cluster.id
    network_id    = data.vsphere_network.network.id
    template_id   = data.vsphere_virtual_machine.template.id
    
    resource_pool_id = module.vsphere_base.resource_pool_id
    vm_folder_id     = module.vsphere_base.vm_folder_id
  }
}

# Management cluster environment
module "management_cluster" {
  source = "./environments/mgmt"

  vm_config   = local.common_vm_config
  cluster_config = var.management_cluster_config
  common_tags = var.common_tags
}

# Development cluster environment
module "dev_cluster" {
  source = "./environments/dev"

  vm_config      = local.common_vm_config
  cluster_config = var.dev_cluster_config
  common_tags    = var.common_tags
  
  depends_on = [module.management_cluster]
}

# Production cluster environment
module "prod_cluster" {
  source = "./environments/prod"

  vm_config      = local.common_vm_config
  cluster_config = var.prod_cluster_config
  common_tags    = var.common_tags
  
  depends_on = [module.management_cluster]
}
