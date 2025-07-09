# TKG Infrastructure with ArgoCD GitOps

This repository contains the complete infrastructure setup for VMware Tanzu Kubernetes Grid (TKG) with ArgoCD for GitOps deployment.

## Architecture Overview

- **Management Cluster**: TKG management cluster for lifecycle management
- **Workload Clusters**: Production and staging TKG clusters
- **ArgoCD**: GitOps continuous deployment
- **Monitoring**: Prometheus, Grafana, and Alertmanager
- **Networking**: Contour ingress controller
- **Security**: Pod Security Standards, Network Policies

## Prerequisites

- VMware vSphere 7.0+
- TKG CLI 2.0+
- kubectl
- helm
- git

## Quick Start

1. **Deploy Management Cluster**
   ```bash
   tanzu management-cluster create --file ./clusters/management/mgmt-cluster.yaml
   ```

2. **Deploy Workload Clusters**
   ```bash
   tanzu cluster create --file ./clusters/workload/prod-cluster.yaml
   tanzu cluster create --file ./clusters/workload/staging-cluster.yaml
   ```

3. **Install ArgoCD**
   ```bash
   kubectl apply -k ./argocd/base
   ```

4. **Deploy Applications**
   ```bash
   kubectl apply -f ./apps/
   ```

## Directory Structure

```
├── clusters/           # TKG cluster configurations
├── argocd/            # ArgoCD installation and configuration
├── apps/              # Application deployments
├── monitoring/        # Prometheus, Grafana setup
├── networking/        # Ingress and network policies
├── security/          # Security policies and RBAC
└── scripts/           # Automation scripts
```

## Documentation

- [Cluster Setup Guide](./docs/cluster-setup.md)
- [ArgoCD Configuration](./docs/argocd-setup.md)
- [Monitoring Setup](./docs/monitoring.md)
- [Security Best Practices](./docs/security.md)

## Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

MIT License - see [LICENSE](LICENSE) file for details.
