# Troubleshooting Guide

## Common Issues and Solutions

### 1. Cluster Creation Issues

#### Problem: Management cluster creation fails

**Symptoms:**
- Cluster creation hangs or fails
- Bootstrap cluster creation errors
- Timeout during cluster initialization

**Solutions:**

1. **Check vSphere connectivity:**
   ```bash
   # Test vCenter connectivity
   curl -k https://vcenter.example.com/sdk
   
   # Verify credentials
   govc about -k
   ```

2. **Verify network connectivity:**
   ```bash
   # Check DNS resolution
   nslookup vcenter.example.com
   
   # Test network connectivity
   ping 192.168.1.10
   ```

3. **Check resource availability:**
   ```bash
   # Check CPU and memory resources
   govc object.collect -s /datacenter/host/cluster -property summary.totalCpu
   ```

#### Problem: Bootstrap cluster cleanup fails

**Solution:**
```bash
# Force cleanup bootstrap cluster
kind delete cluster --name tkg-kind-bootstrap

# Clean up kubeconfig
kubectl config delete-context tkg-kind-bootstrap
```

### 2. Node Issues

#### Problem: Nodes in NotReady state

**Symptoms:**
- Nodes show as NotReady
- Pods cannot be scheduled
- Network connectivity issues

**Diagnosis:**
```bash
# Check node status
kubectl get nodes -o wide

# Describe problematic node
kubectl describe node <node-name>

# Check kubelet logs
kubectl logs -n kube-system -l component=kubelet
```

**Solutions:**

1. **Restart kubelet:**
   ```bash
   # SSH to node and restart kubelet
   sudo systemctl restart kubelet
   ```

2. **Check CNI configuration:**
   ```bash
   # Verify CNI plugin
   kubectl get pods -n kube-system | grep cni
   
   # Check network policy
   kubectl get networkpolicy --all-namespaces
   ```

### 3. Networking Issues

#### Problem: Pod-to-pod communication fails

**Diagnosis:**
```bash
# Test pod connectivity
kubectl exec -it test-pod -- ping 10.96.0.1

# Check service endpoints
kubectl get endpoints

# Verify DNS resolution
kubectl exec -it test-pod -- nslookup kubernetes.default.svc.cluster.local
```

**Solutions:**

1. **Check network policies:**
   ```bash
   # List network policies
   kubectl get networkpolicy --all-namespaces
   
   # Temporarily remove network policy for testing
   kubectl delete networkpolicy <policy-name> -n <namespace>
   ```

2. **Verify CNI plugin:**
   ```bash
   # Check CNI pods
   kubectl get pods -n kube-system | grep cni
   
   # Restart CNI pods
   kubectl delete pod -n kube-system -l k8s-app=cilium
   ```

### 4. Storage Issues

#### Problem: Persistent volumes not mounting

**Symptoms:**
- Pods stuck in pending state
- Volume mounting errors
- Storage class not found

**Diagnosis:**
```bash
# Check persistent volume claims
kubectl get pvc --all-namespaces

# Describe problematic PVC
kubectl describe pvc <pvc-name>

# Check storage class
kubectl get storageclass
```

**Solutions:**

1. **Verify storage class:**
   ```bash
   # Check available storage classes
   kubectl get storageclass -o wide
   
   # Create missing storage class
   kubectl apply -f - <<EOF
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: fast-ssd
   provisioner: csi.vsphere.vmware.com
   parameters:
     storagepolicyname: "vSAN Default Storage Policy"
   EOF
   ```

2. **Check CSI driver:**
   ```bash
   # Check CSI driver pods
   kubectl get pods -n kube-system | grep csi
   
   # Check CSI driver logs
   kubectl logs -n kube-system -l app=vsphere-csi-controller
   ```

### 5. Certificate Issues

#### Problem: Certificate validation failures

**Symptoms:**
- TLS handshake failures
- Certificate expired errors
- Webhook admission errors

**Diagnosis:**
```bash
# Check certificate expiration
kubectl get secret -n kube-system -o jsonpath='{range .items[?(@.type=="kubernetes.io/tls")]}{.metadata.name}{": "}{.data.tls\.crt}{"
"}{end}' | while read name cert; do echo "=== $name ==="; echo $cert | base64 -d | openssl x509 -noout -dates; done

# Check webhook configurations
kubectl get validatingwebhookconfiguration
kubectl get mutatingwebhookconfiguration
```

**Solutions:**

1. **Renew certificates:**
   ```bash
   # Check cert-manager if installed
   kubectl get certificate --all-namespaces
   
   # Force certificate renewal
   kubectl annotate certificate <cert-name> cert-manager.io/issue-temporary-certificate=true
   ```

2. **Recreate webhook configurations:**
   ```bash
   # Delete and recreate webhook
   kubectl delete validatingwebhookconfiguration <webhook-name>
   kubectl apply -f <webhook-config.yaml>
   ```

### 6. Resource Exhaustion

#### Problem: Cluster running out of resources

**Symptoms:**
- Pods stuck in pending state
- Node pressure conditions
- OOM killed containers

**Diagnosis:**
```bash
# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Check node conditions
kubectl describe nodes | grep -A 5 Conditions

# Check resource requests and limits
kubectl describe pod <pod-name> | grep -A 10 Resources
```

**Solutions:**

1. **Scale cluster:**
   ```bash
   # Add worker nodes
   tanzu cluster scale <cluster-name> --worker-machine-count 5
   ```

2. **Optimize resource usage:**
   ```bash
   # Set resource limits
   kubectl apply -f - <<EOF
   apiVersion: v1
   kind: LimitRange
   metadata:
     name: default-limits
   spec:
     limits:
     - default:
         cpu: 500m
         memory: 512Mi
       defaultRequest:
         cpu: 100m
         memory: 128Mi
       type: Container
   EOF
   ```

### 7. ArgoCD Issues

#### Problem: ArgoCD application sync failures

**Symptoms:**
- Applications stuck in OutOfSync state
- Git repository access errors
- Sync operation failures

**Diagnosis:**
```bash
# Check ArgoCD application status
kubectl get applications -n argocd

# Describe problematic application
kubectl describe application <app-name> -n argocd

# Check ArgoCD server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

**Solutions:**

1. **Refresh repository:**
   ```bash
   # Refresh repository in ArgoCD
   argocd repo get https://github.com/your-org/repo.git
   
   # Force refresh
   argocd app sync <app-name> --force
   ```

2. **Check repository access:**
   ```bash
   # Test repository access
   argocd repo list
   
   # Update repository credentials
   argocd repo add https://github.com/your-org/repo.git --username <username> --password <password>
   ```

### 8. Backup and Recovery Issues

#### Problem: Velero backup failures

**Symptoms:**
- Backup operations fail
- Restore operations incomplete
- Storage access errors

**Diagnosis:**
```bash
# Check backup status
velero backup get