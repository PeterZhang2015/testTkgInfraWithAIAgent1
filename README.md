# HA VMware vSphere Tanzu Kubernetes Infrastructure

This repository contains the complete infrastructure setup for deploying HA VMware vSphere Tanzu Kubernetes Management Cluster with two worker clusters (dev/prod) and ArgoCD for GitOps deployment.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    vSphere Infrastructure                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   ESXi Host 1   │  │   ESXi Host 2   │  │   ESXi Host 3   │ │
│  │                 │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              vCenter Server (HA)                           │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │           NSX-T / vSphere Networking                       │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Tanzu Kubernetes Grid                         │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │            Management Cluster (HA)                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │ │
│  │  │Control Plane│  │Control Plane│  │Control Plane│        │ │
│  │  │   Node 1    │  │   Node 2    │  │   Node 3    │        │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐                          │ │
│  │  │ Worker Node │  │ Worker Node │                          │ │
│  │  │      1      │  │      2      │                          │ │
│  │  └─────────────┘  └─────────────┘                          │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Development Workload Cluster                  │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │ │
│  │  │Control Plane│  │Control Plane│  │Control Plane│        │ │
│  │  │   Node 1    │  │   Node 2    │  │   Node 3    │        │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │ │
│  │  │ Worker Node │  │ Worker Node │  │ Worker Node │        │ │
│  │  │      1      │  │      2      │  │      3      │        │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Production Workload Cluster                   │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │ │
│  │  │Control Plane│  │Control Plane│  │Control Plane│        │ │
│  │  │   Node 1    │  │   Node 2    │  │   Node 3    │        │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │ │
│  │                                                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │ │
│  │  │ Worker Node │  │ Worker Node │  │ Worker Node │        │ │
│  │  │      1      │  │      2      │  │      3      │        │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Components

- **vSphere Infrastructure**: 3 ESXi hosts with vCenter Server HA and NSX-T networking
- **Management Cluster**: HA setup with 3 control plane nodes and 2 worker nodes
- **Development Cluster**: 3 control plane nodes and 3 worker nodes for development workloads
- **Production Cluster**: 3 control plane nodes and 3 worker nodes for production workloads
- **GitOps**: ArgoCD and Flux for automated deployment and configuration management

## Prerequisites

- VMware vSphere 7.0 or later
- vSphere with Tanzu enabled
- NSX-T 3.0 or later
- kubectl CLI
- tanzu CLI
- ArgoCD CLI
- Helm 3.x
- Terraform 1.0+
- Ansible 2.9+

## Repository Structure

```
tanzu-k8s-deployment/
├── README.md
├── .gitignore
├── docs/
│   ├── architecture.md
│   ├── prerequisites.md
│   ├── deployment-guide.md
│   ├── troubleshooting.md
│   └── security-hardening.md
├── infrastructure/
│   ├── terraform/
│   │   ├── modules/
│   │   │   ├── vsphere-base/
│   │   │   ├── networking/
│   │   │   ├── storage/
│   │   │   └── security/
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   ├── prod/
│   │   │   └── mgmt/
│   │   └── main.tf
│   ├── ansible/
│   │   ├── playbooks/
│   │   ├── roles/
│   │   ├── inventories/
│   │   └── group_vars/
│   └── packer/
│       ├── templates/
│       └── scripts/
├── tanzu/
│   ├── management-cluster/
│   │   ├── cluster-config.yaml
│   │   ├── cluster-class.yaml
│   │   ├── bootstrap/
│   │   ├── addons/
│   │   └── monitoring/
│   ├── workload-clusters/
│   │   ├── dev/
│   │   │   ├── cluster-config.yaml
│   │   │   ├── cluster-class.yaml
│   │   │   ├── networking/
│   │   │   ├── storage/
│   │   │   └── security/
│   │   └── prod/
│   │       ├── cluster-config.yaml
│   │       ├── cluster-class.yaml
│   │       ├── networking/
│   │       ├── storage/
│   │       └── security/
│   └── shared/
│       ├── cluster-classes/
│       ├── addons/
│       ├── policies/
│       └── templates/
├── applications/
│   ├── base/
│   │   ├── kustomization.yaml
│   │   └── manifests/
│   ├── overlays/
│   │   ├── dev/
│   │   └── prod/
│   └── helm-charts/
├── gitops/
│   ├── argocd/
│   │   ├── applications/
│   │   ├── projects/
│   │   └── repositories/
│   └── flux/
│       ├── clusters/
│       ├── infrastructure/
│       └── apps/
├── monitoring/
│   ├── prometheus/
│   ├── grafana/
│   ├── alertmanager/
│   └── dashboards/
├── security/
│   ├── rbac/
│   ├── network-policies/
│   ├── pod-security-policies/
│   └── admission-controllers/
├── backup/
│   ├── velero/
│   ├── etcd/
│   └── scripts/
├── scripts/
│   ├── deployment/
│   ├── maintenance/
│   ├── backup-restore/
│   └── utilities/
└── ci-cd/
    ├── jenkins/
    ├── github-actions/
    ├── gitlab-ci/
    └── tekton/
```

## Quick Start

1. **Configure Environment Variables**:
   ```bash
   export VSPHERE_SERVER="your-vcenter-server"
   export VSPHERE_USERNAME="your-username"
   export VSPHERE_PASSWORD="your-password"
   export VSPHERE_DATACENTER="your-datacenter"
   export VSPHERE_DATASTORE="your-datastore"
   export VSPHERE_NETWORK="your-network"
   export VSPHERE_FOLDER="your-vm-folder"
   export VSPHERE_RESOURCE_POOL="your-resource-pool"
   ```

2. **Initialize Infrastructure**:
   ```bash
   # Deploy base infrastructure with Terraform
   cd infrastructure/terraform
   terraform init
   terraform plan
   terraform apply
   
   # Configure hosts with Ansible
   cd ../ansible
   ansible-playbook -i inventories/production playbooks/site.yml
   ```

3. **Deploy Management Cluster**:
   ```bash
   cd tanzu/management-cluster
   tanzu management-cluster create --file cluster-config.yaml
   ```

4. **Deploy Workload Clusters**:
   ```bash
   # Deploy development cluster
   cd ../workload-clusters/dev
   tanzu cluster create --file cluster-config.yaml
   
   # Deploy production cluster  
   cd ../prod
   tanzu cluster create --file cluster-config.yaml
   ```

5. **Setup GitOps**:
   ```bash
   # Install ArgoCD
   cd ../../gitops/argocd
   kubectl apply -f install/
   
   # Configure applications
   kubectl apply -f applications/
   ```

## Usage

### Managing Clusters

```bash
# List all clusters
tanzu cluster list

# Get cluster credentials
tanzu cluster kubeconfig get dev-cluster --admin
tanzu cluster kubeconfig get prod-cluster --admin

# Scale cluster
tanzu cluster scale dev-cluster --worker-machine-count 5

# Update cluster
tanzu cluster update dev-cluster --file updated-config.yaml
```

### Infrastructure Management

```bash
# Update infrastructure
cd infrastructure/terraform
terraform plan
terraform apply

# Run maintenance playbooks
cd ../ansible
ansible-playbook -i inventories/production playbooks/maintenance.yml
```

### GitOps Operations

```bash
# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login to ArgoCD
argocd login localhost:8080

# Sync applications
argocd app sync dev-cluster
argocd app sync prod-cluster
argocd app sync monitoring-stack
```

### Monitoring and Observability

```bash
# Access monitoring dashboards
kubectl port-forward svc/grafana -n monitoring 3000:3000

# Check cluster health
kubectl get nodes
kubectl get pods --all-namespaces
tanzu cluster get dev-cluster
```

## Security Features

- **RBAC**: Role-based access control for clusters and applications
- **Pod Security Standards**: Enforced security policies for workloads
- **Network Policies**: Micro-segmentation for cluster networking
- **Admission Controllers**: Policy enforcement at admission time
- **Image Security**: Container image scanning and signing
- **Secrets Management**: Encrypted storage and rotation of secrets

## Backup and Recovery

- **Velero**: Kubernetes cluster backup and restore
- **ETCD Backup**: Automated ETCD snapshots
- **Disaster Recovery**: Multi-site recovery procedures
- **Data Protection**: Persistent volume backup strategies

## CI/CD Integration

The repository includes templates and configurations for:
- **Jenkins**: Pipeline as code for infrastructure and applications
- **GitHub Actions**: Automated workflows for GitOps
- **GitLab CI**: Container-based CI/CD pipelines
- **Tekton**: Cloud-native CI/CD for Kubernetes

## Monitoring and Maintenance

- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and management
- **Regular Health Checks**: Automated cluster health monitoring
- **Resource Monitoring**: CPU, memory, and storage utilization
- **Security Scanning**: Vulnerability assessment and compliance

## Documentation

Detailed documentation is available in the `docs/` directory:
- [Architecture Guide](docs/architecture.md)
- [Prerequisites](docs/prerequisites.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security Hardening](docs/security-hardening.md)

## Contributing

Please read the contributing guidelines before submitting pull requests. All contributions should follow the established patterns and include appropriate tests.

## License

MIT License