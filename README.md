# HA VMware vSphere Tanzu Kubernetes Infrastructure

This repository contains the complete infrastructure setup for deploying HA VMware vSphere Tanzu Kubernetes Management Cluster with two worker clusters (dev/prod) and ArgoCD for GitOps deployment.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    vSphere Infrastructure                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │           Management Cluster (HA)                      │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │
│  │  │   Master    │  │   Master    │  │   Master    │    │ │
│  │  │   Node 1    │  │   Node 2    │  │   Node 3    │    │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘    │ │
│  │                                                        │ │
│  │  ┌─────────────┐  ┌─────────────┐                     │ │
│  │  │   Worker    │  │   Worker    │                     │ │
│  │  │   Node 1    │  │   Node 2    │                     │ │
│  │  └─────────────┘  └─────────────┘                     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Dev Cluster                              │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │
│  │  │   Worker    │  │   Worker    │  │   Worker    │    │ │
│  │  │   Node 1    │  │   Node 2    │  │   Node 3    │    │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                Prod Cluster                             │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │ │
│  │  │   Worker    │  │   Worker    │  │   Worker    │    │ │
│  │  │   Node 1    │  │   Node 2    │  │   Node 3    │    │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘    │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Components

- **Management Cluster**: HA setup with 3 master nodes and 2 worker nodes
- **Dev Cluster**: 3 worker nodes for development workloads
- **Prod Cluster**: 3 worker nodes for production workloads
- **ArgoCD**: GitOps deployment for cluster management and application deployment

## Prerequisites

- VMware vSphere 7.0 or later
- vSphere with Tanzu enabled
- kubectl CLI
- tanzu CLI
- ArgoCD CLI
- Helm 3.x

## Directory Structure

```
.
├── clusters/
│   ├── management/
│   │   ├── cluster-config.yaml
│   │   ├── bootstrap.sh
│   │   └── argocd-install.yaml
│   ├── dev/
│   │   ├── cluster-config.yaml
│   │   └── cluster-class.yaml
│   └── prod/
│       ├── cluster-config.yaml
│       └── cluster-class.yaml
├── argocd/
│   ├── applications/
│   │   ├── dev-cluster.yaml
│   │   ├── prod-cluster.yaml
│   │   └── sample-app.yaml
│   ├── projects/
│   │   └── default.yaml
│   └── install/
│       └── argocd-install.yaml
├── applications/
│   ├── dev/
│   │   ├── sample-app/
│   │   └── kustomization.yaml
│   └── prod/
│       ├── sample-app/
│       └── kustomization.yaml
└── scripts/
    ├── 01-bootstrap-management.sh
    ├── 02-deploy-clusters.sh
    └── 03-setup-argocd.sh
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

2. **Deploy Management Cluster**:
   ```bash
   ./scripts/01-bootstrap-management.sh
   ```

3. **Deploy Worker Clusters**:
   ```bash
   ./scripts/02-deploy-clusters.sh
   ```

4. **Setup ArgoCD**:
   ```bash
   ./scripts/03-setup-argocd.sh
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
```

### ArgoCD Operations

```bash
# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login to ArgoCD
argocd login localhost:8080

# Sync applications
argocd app sync dev-cluster
argocd app sync prod-cluster
```

## Monitoring and Maintenance

- Check cluster health regularly
- Monitor resource usage
- Keep TKG components updated
- Review ArgoCD sync status

## Security Considerations

- Use RBAC for cluster access
- Enable Pod Security Standards
- Configure network policies
- Regular security updates

## Troubleshooting

See individual component README files for specific troubleshooting steps.

## Contributing

Please read the contributing guidelines before submitting pull requests.

## License

MIT License