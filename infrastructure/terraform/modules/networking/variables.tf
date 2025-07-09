# Networking Module Variables

variable "datacenter" {
  description = "Name of the vSphere datacenter"
  type        = string
}

variable "esxi_hosts" {
  description = "List of ESXi hosts in the cluster"
  type        = list(string)
}

variable "dvs_name" {
  description = "Name of the distributed virtual switch"
  type        = string
}

variable "overlay_tz_name" {
  description = "Name of the NSX-T overlay transport zone"
  type        = string
}

variable "vlan_tz_name" {
  description = "Name of the NSX-T VLAN transport zone"
  type        = string
}

variable "edge_cluster_name" {
  description = "Name of the NSX-T edge cluster"
  type        = string
}

variable "tier0_gateway_name" {
  description = "Name of the Tier-0 gateway"
  type        = string
  default     = "tier0-gateway"
}

variable "mgmt_tier1_gateway_name" {
  description = "Name of the management Tier-1 gateway"
  type        = string
  default     = "mgmt-tier1-gateway"
}

variable "workload_tier1_gateway_name" {
  description = "Name of the workload Tier-1 gateway"
  type        = string
  default     = "workload-tier1-gateway"
}

variable "bgp_local_as" {
  description = "Local AS number for BGP configuration"
  type        = number
  default     = 65000
}

variable "mgmt_segment_name" {
  description = "Name of the management segment"
  type        = string
  default     = "mgmt-segment"
}

variable "mgmt_segment_cidr" {
  description = "CIDR block for management segment"
  type        = string
  default     = "10.10.10.0/24"
}

variable "mgmt_dhcp_ranges" {
  description = "DHCP ranges for management segment"
  type        = list(string)
  default     = ["10.10.10.100-10.10.10.200"]
}

variable "dev_segment_name" {
  description = "Name of the development segment"
  type        = string
  default     = "dev-segment"
}

variable "dev_segment_cidr" {
  description = "CIDR block for development segment"
  type        = string
  default     = "10.20.10.0/24"
}

variable "dev_dhcp_ranges" {
  description = "DHCP ranges for development segment"
  type        = list(string)
  default     = ["10.20.10.100-10.20.10.200"]
}

variable "prod_segment_name" {
  description = "Name of the production segment"
  type        = string
  default     = "prod-segment"
}

variable "prod_segment_cidr" {
  description = "CIDR block for production segment"
  type        = string
  default     = "10.30.10.0/24"
}

variable "prod_dhcp_ranges" {
  description = "DHCP ranges for production segment"
  type        = list(string)
  default     = ["10.30.10.100-10.30.10.200"]
}

variable "mgmt_dhcp_server_addresses" {
  description = "DHCP server addresses for management"
  type        = list(string)
  default     = ["10.10.10.2/24"]
}

variable "dev_dhcp_server_addresses" {
  description = "DHCP server addresses for development"
  type        = list(string)
  default     = ["10.20.10.2/24"]
}

variable "prod_dhcp_server_addresses" {
  description = "DHCP server addresses for production"
  type        = list(string)
  default     = ["10.30.10.2/24"]
}

variable "dhcp_lease_time" {
  description = "DHCP lease time in seconds"
  type        = number
  default     = 86400
}

variable "lb_size" {
  description = "Size of the load balancer"
  type        = string
  default     = "SMALL"
}

variable "mgmt_portgroup_name" {
  description = "Name of the management port group"
  type        = string
  default     = "mgmt-portgroup"
}

variable "mgmt_vlan_id" {
  description = "VLAN ID for management port group"
  type        = number
  default     = 100
}

variable "dev_portgroup_name" {
  description = "Name of the development port group"
  type        = string
  default     = "dev-portgroup"
}

variable "dev_vlan_id" {
  description = "VLAN ID for development port group"
  type        = number
  default     = 200
}

variable "prod_portgroup_name" {
  description = "Name of the production port group"
  type        = string
  default     = "prod-portgroup"
}

variable "prod_vlan_id" {
  description = "VLAN ID for production port group"
  type        = number
  default     = 300
}
