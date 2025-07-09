# Prerequisites

## Hardware Requirements

### vSphere Infrastructure
- **ESXi Hosts**: Minimum 3 hosts for HA
- **CPU**: 64+ cores per host with hyperthreading
- **Memory**: 512GB+ RAM per host
- **Storage**: 2TB+ SSD storage per host
- **Network**: 10GbE or faster network adapters

### Minimum Resource Allocation
- **Management Cluster**: 3 control plane nodes (4 vCPU, 16GB RAM each)
- **Development Cluster**: 3 control plane + 3 worker nodes (4 vCPU, 16GB RAM each)
- **Production Cluster**: 3 control plane + 3 worker nodes (8 vCPU, 32GB RAM each)

## Software Requirements

### VMware Components
- vSphere 7.0 U3 or later
- vCenter Server 7.0 U3 or later
- NSX-T 3.2 or later (optional)
- vSAN 7.0 U3 or later (if using vSAN)

### Operating System
- Ubuntu 20.04 LTS or later
- VMware Photon OS 4.0 or later
- CentOS 8 or later

## Network Requirements

### Network Segments
- Management network (for cluster communication)
- Workload network (for application traffic)
- Load balancer network (for external access)
- Storage network (for vSAN or shared storage)

### Firewall Rules
- ESXi management ports (443, 902, 5988)
- vCenter Server ports (443, 9443)
- Kubernetes API server (6443)
- etcd client/peer communication (2379, 2380)
- kubelet (10250)
- NodePort services (30000-32767)

## DNS and NTP

### DNS Configuration
- Forward and reverse DNS resolution
- Wildcard DNS for application ingress
- DNS records for load balancers

### NTP Configuration
- Consistent time synchronization across all components
- NTP server accessibility from all nodes

## SSL Certificates

### Certificate Requirements
- Valid SSL certificates for vCenter Server
- Wildcard certificates for Kubernetes ingress
- Certificate authority for internal communication

## Storage Requirements

### Persistent Storage
- vSAN or external shared storage
- Storage classes for different performance tiers
- Snapshot and backup capabilities

### Backup Storage
- Separate backup storage for cluster backups
- Offsite backup for disaster recovery

## User Access and Permissions

### vSphere Permissions
- Administrator access to vCenter Server
- Appropriate permissions for Tanzu service accounts
- Network and storage permissions

### Kubernetes Access
- RBAC configuration for user access
- Service account management
- Secret and ConfigMap permissions

## Monitoring and Logging

### Monitoring Infrastructure
- Prometheus and Grafana setup
- Persistent storage for metrics
- Alerting infrastructure

### Logging Infrastructure
- Centralized logging system
- Log retention policies
- Log analysis capabilities

## Backup and Recovery

### Backup Strategy
- Regular etcd backups
- VM-level backups
- Application-level backups
- Configuration backups

### Recovery Testing
- Regular recovery testing procedures
- Documented recovery processes
- Recovery time objectives (RTO) and recovery point objectives (RPO)