# Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying a highly available Tanzu Kubernetes Grid infrastructure on VMware vSphere.

## Phase 1: Infrastructure Preparation

### 1.1 vSphere Environment Setup

1. **Configure ESXi Hosts**
   ```bash
   # Configure NTP on ESXi hosts
   esxcli system ntp set --enabled=true --server=ntp.example.com
   
   # Configure DNS
   esxcli network ip dns server add --server=192.168.1.10
   ```

2. **Set up vCenter Server**
   - Deploy vCenter Server in HA mode
   - Configure SSO domain
   - Add ESXi hosts to vCenter

3. **Configure Storage**
   - Set up vSAN or external shared storage
   - Create storage policies
   - Configure backup storage

### 1.2 Network Configuration

1. **Create Network Segments**
   ```bash
   # Example network configuration
   # Management Network: 192.168.1.0/24
   # Workload Network: 192.168.2.0/24
   # Load Balancer Network: 192.168.3.0/24
   ```

2. **Configure Load Balancer**
   - Deploy HAProxy or NSX-T load balancer
   - Configure VIP pools
   - Set up health checks

## Phase 2: Prepare Base Images

### 2.1 Create VM Templates with Packer

1. **Install Packer**
   ```bash
   # Install Packer
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install packer
   ```

2. **Create Base Template**
   ```bash
   # Navigate to packer directory
   cd infrastructure/packer/templates
   
   # Build Ubuntu template
   packer build ubuntu-20.04-template.json
   ```

### 2.2 Configure Templates

1. **Install Required Packages**
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # Install kubectl
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

## Phase 3: Deploy Management Cluster

### 3.1 Install Tanzu CLI

1. **Download and Install Tanzu CLI**
   ```bash
   # Download Tanzu CLI
   curl -H "Accept: application/vnd.github.v3.raw" -L -o tanzu-cli.tar.gz https://github.com/vmware-tanzu/tanzu-cli/releases/download/v1.0.0/tanzu-cli-linux-amd64.tar.gz
   
   # Extract and install
   tar -xzf tanzu-cli.tar.gz
   sudo install tanzu-cli-linux-amd64/tanzu /usr/local/bin/
   ```

2. **Initialize Tanzu CLI**
   ```bash
   tanzu init
   tanzu plugin install --local cli-all
   ```

### 3.2 Bootstrap Management Cluster

1. **Configure Bootstrap Configuration**
   ```bash
   # Create bootstrap directory
   mkdir -p ~/.config/tanzu/tkg/clusterconfigs
   
   # Copy configuration template
   cp tanzu/management-cluster/cluster-config.yaml ~/.config/tanzu/tkg/clusterconfigs/
   ```

2. **Deploy Management Cluster**
   ```bash
   # Initialize management cluster
   tanzu management-cluster create --file cluster-config.yaml
   
   # Verify deployment
   tanzu management-cluster get
   ```

### 3.3 Configure Management Cluster

1. **Install Essential Addons**
   ```bash
   # Install cert-manager
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
   
   # Install Contour ingress controller
   kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
   ```

2. **Set up Monitoring**
   ```bash
   # Install Prometheus
   kubectl apply -f monitoring/prometheus/
   
   # Install Grafana
   kubectl apply -f monitoring/grafana/
   ```

## Phase 4: Deploy Workload Clusters

### 4.1 Development Cluster

1. **Configure Development Cluster**
   ```bash
   # Create development cluster
   tanzu cluster create dev-cluster --file tanzu/workload-clusters/dev/cluster-config.yaml
   
   # Get cluster credentials
   tanzu cluster kubeconfig get dev-cluster --admin
   ```

2. **Configure Development Tools**
   ```bash
   # Switch to development cluster context
   kubectl config use-context dev-cluster-admin@dev-cluster
   
   # Install development tools
   helm install jenkins jenkins/jenkins -n jenkins --create-namespace
   ```

### 4.2 Production Cluster

1. **Configure Production Cluster**
   ```bash
   # Create production cluster
   tanzu cluster create prod-cluster --file tanzu/workload-clusters/prod/cluster-config.yaml
   
   # Get cluster credentials
   tanzu cluster kubeconfig get prod-cluster --admin
   ```

2. **Apply Security Policies**
   ```bash
   # Switch to production cluster context
   kubectl config use-context prod-cluster-admin@prod-cluster
   
   # Apply security policies
   kubectl apply -f security/rbac/
   kubectl apply -f security/network-policies/
   kubectl apply -f security/pod-security-policies/
   ```

## Phase 5: Configure GitOps

### 5.1 Install ArgoCD

1. **Deploy ArgoCD**
   ```bash
   # Create ArgoCD namespace
   kubectl create namespace argocd
   
   # Install ArgoCD
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. **Configure ArgoCD**
   ```bash
   # Apply ArgoCD configuration
   kubectl apply -f gitops/argocd/
   ```

### 5.2 Configure Application Deployment

1. **Set up Application Repositories**
   ```bash
   # Add application repository
   argocd repo add https://github.com/your-org/app-repo.git
   ```

2. **Create Application Manifests**
   ```bash
   # Apply application configurations
   kubectl apply -f applications/
   ```

## Phase 6: Configure Backup and Monitoring

### 6.1 Set up Backup with Velero

1. **Install Velero**
   ```bash
   # Install Velero CLI
   curl -fsSL -o velero-linux-amd64.tar.gz https://github.com/vmware-tanzu/velero/releases/download/v1.11.0/velero-v1.11.0-linux-amd64.tar.gz
   tar -xzf velero-linux-amd64.tar.gz
   sudo mv velero-v1.11.0-linux-amd64/velero /usr/local/bin/
   
   # Install Velero server
   velero install --provider aws --plugins velero/velero-plugin-for-aws:v1.7.0 --bucket my-backup-bucket --secret-file ./credentials-velero --backup-location-config region=us-east-1
   ```

2. **Configure Backup Schedules**
   ```bash
   # Create backup schedule
   velero schedule create daily-backup --schedule="0 2 * * *" --ttl 720h
   ```

### 6.2 Complete Monitoring Setup

1. **Configure Alerting**
   ```bash
   # Apply alerting rules
   kubectl apply -f monitoring/alertmanager/
   ```

2. **Import Grafana Dashboards**
   ```bash
   # Import dashboard configurations
   kubectl apply -f monitoring/dashboards/
   ```

## Verification

### 6.1 Verify Cluster Health

```bash
# Check cluster status
tanzu cluster list

# Check node status
kubectl get nodes -o wide

# Check pod status
kubectl get pods --all-namespaces
```

### 6.2 Test Application Deployment

```bash
# Deploy test application
kubectl apply -f applications/base/test-app.yaml

# Check deployment
kubectl get deployment test-app
```

## Next Steps

1. Configure additional workload clusters as needed
2. Implement custom monitoring and alerting rules
3. Set up automated testing and validation
4. Configure disaster recovery procedures
5. Implement cost optimization strategies