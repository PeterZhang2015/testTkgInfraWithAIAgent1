# Networking Module for NSX-T/vSphere Network Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
    nsxt = {
      source  = "vmware/nsxt"
      version = "~> 3.0"
    }
  }
}

# Data sources for vSphere objects
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_host" "hosts" {
  count         = length(var.esxi_hosts)
  name          = var.esxi_hosts[count.index]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.dvs_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# NSX-T Configuration
data "nsxt_policy_transport_zone" "overlay" {
  display_name = var.overlay_tz_name
}

data "nsxt_policy_transport_zone" "vlan" {
  display_name = var.vlan_tz_name
}

data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = var.edge_cluster_name
}

# Create NSX-T Tier-0 Gateway
resource "nsxt_policy_tier0_gateway" "tier0_gw" {
  display_name      = var.tier0_gateway_name
  description       = "Tier-0 Gateway for Tanzu Kubernetes Infrastructure"
  failover_mode     = "PREEMPTIVE"
  default_rule_logging = false
  enable_firewall   = true
  ha_mode          = "ACTIVE_STANDBY"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path

  bgp_config {
    ecmp            = true
    local_as_num    = var.bgp_local_as
    inter_sr_ibgp   = true
    multipath_relax = true
  }

  tag {
    scope = "project"
    tag   = "tanzu-k8s"
  }
}

# Create NSX-T Tier-1 Gateway for Management
resource "nsxt_policy_tier1_gateway" "mgmt_tier1_gw" {
  display_name                = var.mgmt_tier1_gateway_name
  description                 = "Tier-1 Gateway for Management Cluster"
  edge_cluster_path           = data.nsxt_policy_edge_cluster.edge_cluster.path
  failover_mode               = "PREEMPTIVE"
  default_rule_logging        = false
  enable_firewall             = true
  enable_standby_relocation   = false
  tier0_path                  = nsxt_policy_tier0_gateway.tier0_gw.path
  route_advertisement_types   = ["TIER1_CONNECTED"]

  tag {
    scope = "project"
    tag   = "tanzu-k8s"
  }
}

# Create NSX-T Tier-1 Gateway for Workload Clusters
resource "nsxt_policy_tier1_gateway" "workload_tier1_gw" {
  display_name                = var.workload_tier1_gateway_name
  description                 = "Tier-1 Gateway for Workload Clusters"
  edge_cluster_path           = data.nsxt_policy_edge_cluster.edge_cluster.path
  failover_mode               = "PREEMPTIVE"
  default_rule_logging        = false
  enable_firewall             = true
  enable_standby_relocation   = false
  tier0_path                  = nsxt_policy_tier0_gateway.tier0_gw.path
  route_advertisement_types   = ["TIER1_CONNECTED"]

  tag {
    scope = "project"
    tag   = "tanzu-k8s"
  }
}

# Create network segments for management cluster
resource "nsxt_policy_segment" "mgmt_segment" {
  display_name        = var.mgmt_segment_name
  description         = "Management cluster network segment"
  connectivity_path   = nsxt_policy_tier1_gateway.mgmt_tier1_gw.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay.path

  subnet {
    cidr        = var.mgmt_segment_cidr
    dhcp_ranges = var.mgmt_dhcp_ranges
  }

  tag {
    scope = "project"
    tag   = "tanzu-k8s"
  }
}

# Create network segments for development workload cluster
resource "nsxt_policy_segment" "dev_segment" {
  display_name        = var.dev_segment_name
  description         = "Development cluster network segment"
  connectivity_path   = nsxt_policy_tier1_gateway.workload_tier1_gw.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay.path

  subnet {
    cidr        = var.dev_segment_cidr
    dhcp_ranges = var.dev_dhcp_ranges
  }

  tag {
    scope = "project"
    tag   = "tanzu-k8s"
  }
}

# Create network segments for production workload cluster
resource "nsxt_policy_segment" "prod_segment" {
  display_name        = var.prod_segment_name
  description         = "Production cluster network segment"
  connectivity_path   = nsxt_policy_tier1_gateway.workload_tier1_gw.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay.path

  subnet {
    cidr        = var.prod_segment_cidr
    dhcp_ranges = var.prod_dhcp_ranges
  }

  tag {
    scope = "project"
    tag   = "tanzu-k8s"
  }
}

# Create DHCP configuration for management cluster
resource "nsxt_policy_dhcp_server" "mgmt_dhcp" {
  display_name     = "mgmt-dhcp-server"
  description      = "DHCP server for management cluster"
  server_addresses = var.mgmt_dhcp_server_addresses
  lease_time       = var.dhcp_lease_time
}

# Create DHCP configuration for development cluster
resource "nsxt_policy_dhcp_server" "dev_dhcp" {
  display_name     = "dev-dhcp-server"
  description      = "DHCP server for development cluster"
  server_addresses = var.dev_dhcp_server_addresses
  lease_time       = var.dhcp_lease_time
}

# Create DHCP configuration for production cluster
resource "nsxt_policy_dhcp_server" "prod_dhcp" {
  display_name     = "prod-dhcp-server"
  description      = "DHCP server for production cluster"
  server_addresses = var.prod_dhcp_server_addresses
  lease_time       = var.dhcp_lease_time
}

# Create Load Balancer for management cluster
resource "nsxt_policy_lb_service" "mgmt_lb" {
  display_name      = "mgmt-lb-service"
  description       = "Load balancer for management cluster"
  connectivity_path = nsxt_policy_tier1_gateway.mgmt_tier1_gw.path
  size              = var.lb_size
  enabled           = true

  tag {
    scope = "project"
    tag   = "tanzu-k8s"
  }
}

# Create Load Balancer for workload clusters
resource "nsxt_policy_lb_service" "workload_lb" {
  display_name      = "workload-lb-service"
  description       = "Load balancer for workload clusters"
  connectivity_path = nsxt_policy_tier1_gateway.workload_tier1_gw.path
  size              = var.lb_size
  enabled           = true

  tag {
    scope = "project"
    tag   = "tanzu-k8s"
  }
}

# Create distributed port groups for vSphere networking
resource "vsphere_distributed_port_group" "mgmt_portgroup" {
  name                            = var.mgmt_portgroup_name
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = var.mgmt_vlan_id
  
  vlan_override_allowed      = true
  netflow_override_allowed   = true
  security_policy_override_allowed = true
  shaping_override_allowed   = true
  traffic_filter_override_allowed = true
  uplink_teaming_override_allowed = true

  policy {
    live_port_moving_allowed = true
    network_resource_pool_override_allowed = true
    port_config_reset_at_disconnect = true
    block_override_allowed = true
    shaping_override_allowed = true
    vendor_config_override_allowed = true
    security_policy_override_allowed = true
    uplink_teaming_override_allowed = true
  }
}

resource "vsphere_distributed_port_group" "dev_portgroup" {
  name                            = var.dev_portgroup_name
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = var.dev_vlan_id
  
  vlan_override_allowed      = true
  netflow_override_allowed   = true
  security_policy_override_allowed = true
  shaping_override_allowed   = true
  traffic_filter_override_allowed = true
  uplink_teaming_override_allowed = true

  policy {
    live_port_moving_allowed = true
    network_resource_pool_override_allowed = true
    port_config_reset_at_disconnect = true
    block_override_allowed = true
    shaping_override_allowed = true
    vendor_config_override_allowed = true
    security_policy_override_allowed = true
    uplink_teaming_override_allowed = true
  }
}

resource "vsphere_distributed_port_group" "prod_portgroup" {
  name                            = var.prod_portgroup_name
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = var.prod_vlan_id
  
  vlan_override_allowed      = true
  netflow_override_allowed   = true
  security_policy_override_allowed = true
  shaping_override_allowed   = true
  traffic_filter_override_allowed = true
  uplink_teaming_override_allowed = true

  policy {
    live_port_moving_allowed = true
    network_resource_pool_override_allowed = true
    port_config_reset_at_disconnect = true
    block_override_allowed = true
    shaping_override_allowed = true
    vendor_config_override_allowed = true
    security_policy_override_allowed = true
    uplink_teaming_override_allowed = true
  }
}
