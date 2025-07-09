#!/bin/bash

# Bootstrap script for TKG Management Cluster
# This script initializes the management cluster with HA configuration

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if required tools are installed
    local tools=("kubectl" "tanzu" "helm")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "$tool is not installed or not in PATH"
        fi
    done
    
    # Check required environment variables
    local required_vars=(
        "VSPHERE_SERVER"
        "VSPHERE_USERNAME"
        "VSPHERE_PASSWORD"
        "VSPHERE_DATACENTER"
        "VSPHERE_DATASTORE"
        "VSPHERE_NETWORK"
        "VSPHERE_FOLDER"
        "VSPHERE_RESOURCE_POOL"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            error "Environment variable $var is not set"
        fi
    done
    
    log "Prerequisites check passed"
}

# Initialize TKG management cluster
init_management_cluster() {
    log "Initializing TKG management cluster..."
    
    # Create management cluster configuration
    cat > /tmp/management-cluster-config.yaml << EOF
CLUSTER_NAME: management-cluster
CLUSTER_PLAN: prod
INFRASTRUCTURE_PROVIDER: vsphere
ENABLE_CEIP_PARTICIPATION: false
ENABLE_AUDIT_LOGGING: true
CLUSTER_CIDR: 100.96.0.0/11
SERVICE_CIDR: 100.64.0.0/13
CNI: antrea

# vSphere configuration
VSPHERE_SERVER: ${VSPHERE_SERVER}
VSPHERE_USERNAME: ${VSPHERE_USERNAME}
VSPHERE_PASSWORD: ${VSPHERE_PASSWORD}
VSPHERE_DATACENTER: ${VSPHERE_DATACENTER}
VSPHERE_DATASTORE: ${VSPHERE_DATASTORE}
VSPHERE_NETWORK: ${VSPHERE_NETWORK}
VSPHERE_FOLDER: ${VSPHERE_FOLDER}
VSPHERE_RESOURCE_POOL: ${VSPHERE_RESOURCE_POOL}
VSPHERE_SSH_AUTHORIZED_KEY: $(cat ~/.ssh/id_rsa.pub)
VSPHERE_TLS_THUMBPRINT: ${VSPHERE_TLS_THUMBPRINT:-}

# Control plane configuration for HA
CONTROL_PLANE_MACHINE_COUNT: 3
WORKER_MACHINE_COUNT: 2

# Machine specifications
VSPHERE_CONTROL_PLANE_NUM_CPUS: 4
VSPHERE_CONTROL_PLANE_MEM_MIB: 8192
VSPHERE_CONTROL_PLANE_DISK_GIB: 40
VSPHERE_WORKER_NUM_CPUS: 4
VSPHERE_WORKER_MEM_MIB: 8192
VSPHERE_WORKER_DISK_GIB: 40

# OS configuration
OS_NAME: ubuntu
OS_VERSION: 20.04
OS_ARCH: amd64

# Enable features
ENABLE_CLUSTER_OPTIONS: true
ENABLE_IDENTITY_MANAGEMENT: true
IDENTITY_MANAGEMENT_TYPE: oidc
OIDC_ISSUER_URL: https://your-oidc-provider.com
OIDC_CLIENT_ID: kubernetes
OIDC_USERNAME_CLAIM: email
OIDC_GROUPS_CLAIM: groups

# Security settings
ENABLE_DEFAULT_STORAGE_CLASS: true
ENABLE_CLUSTER_TOPOLOGY: true
EOF

    # Initialize the management cluster
    if ! tanzu management-cluster create --file /tmp/management-cluster-config.yaml --timeout 30m; then
        error "Failed to create management cluster"
    fi
    
    log "Management cluster initialized successfully"
}

# Configure kubectl context
configure_kubectl() {
    log "Configuring kubectl context..."
    
    # Get management cluster kubeconfig
    tanzu management-cluster kubeconfig get --admin
    
    # Switch to management cluster context
    kubectl config use-context management-cluster-admin@management-cluster
    
    # Verify cluster is ready
    local retries=0
    local max_retries=30
    while [[ $retries -lt $max_retries ]]; do
        if kubectl get nodes | grep -q "Ready"; then
            log "Management cluster is ready"
            break
        fi
        warn "Waiting for management cluster to be ready... ($((retries+1))/$max_retries)"
        sleep 30
        ((retries++))
    done
    
    if [[ $retries -eq $max_retries ]]; then
        error "Management cluster failed to become ready"
    fi
}

# Install essential addons
install_addons() {
    log "Installing essential addons..."
    
    # Install Contour for ingress
    kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/main/examples/contour/01-crds.yaml
    kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/main/examples/contour/02-rbac.yaml
    kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/main/examples/contour/02-service-monitor.yaml
    kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/main/examples/contour/03-contour.yaml
    
    # Install cert-manager
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
    
    # Wait for cert-manager to be ready
    kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager -n cert-manager
    kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager-cainjector -n cert-manager
    kubectl wait --for=condition=Available --timeout=300s deployment/cert-manager-webhook -n cert-manager
    
    log "Essential addons installed successfully"
}

# Setup RBAC
setup_rbac() {
    log "Setting up RBAC..."
    
    # Create admin role binding
    kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tkg-admin-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: User
  name: admin@example.com
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tkg-developers-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
EOF

    log "RBAC setup completed"
}

# Setup monitoring
setup_monitoring() {
    log "Setting up monitoring..."
    
    # Add Prometheus community helm repo
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Install kube-prometheus-stack
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
        --set grafana.persistence.enabled=true \
        --set grafana.persistence.size=10Gi \
        --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=10Gi
    
    log "Monitoring setup completed"
}

# Main execution
main() {
    log "Starting TKG Management Cluster bootstrap..."
    
    check_prerequisites
    init_management_cluster
    configure_kubectl
    install_addons
    setup_rbac
    setup_monitoring
    
    log "TKG Management Cluster bootstrap completed successfully!"
    log "Management cluster is ready for workload cluster deployment"
    
    # Display cluster information
    echo -e "
${BLUE}Cluster Information:${NC}"
    kubectl cluster-info
    echo -e "
${BLUE}Nodes:${NC}"
    kubectl get nodes -o wide
    echo -e "
${BLUE}Namespaces:${NC}"
    kubectl get namespaces
}

# Trap for cleanup
trap 'error "Bootstrap failed. Check logs for details."' ERR

# Run main function
main "$@"