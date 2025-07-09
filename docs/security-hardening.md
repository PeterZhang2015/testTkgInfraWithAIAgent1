# Security Hardening Guide

This document provides comprehensive security hardening guidelines for the HA VMware vSphere Tanzu Kubernetes infrastructure.

## Table of Contents

1. [Infrastructure Security](#infrastructure-security)
2. [Kubernetes Security](#kubernetes-security)
3. [Container Security](#container-security)
4. [Network Security](#network-security)
5. [Identity and Access Management](#identity-and-access-management)
6. [Secrets Management](#secrets-management)
7. [Monitoring and Auditing](#monitoring-and-auditing)
8. [Compliance and Governance](#compliance-and-governance)

## Infrastructure Security

### vSphere Security

```yaml
# ESXi Host Security Configuration
esxi_security:
  lockdown_mode: "strict"
  ssh_access: "disabled"
  shell_access: "disabled"
  dcui_access: "disabled"
  firewall_enabled: true
  ntp_servers:
    - "time.nist.gov"
    - "pool.ntp.org"
  
# vCenter Security Configuration
vcenter_security:
  sso_policy:
    password_policy: "complex"
    lockout_policy: "enabled"
    session_timeout: "30"
  certificate_management:
    ca_signed_certificates: true
    certificate_rotation: "automatic"
  audit_logging: "enabled"
```

### NSX-T Security

```yaml
# Micro-segmentation Configuration
nsx_microsegmentation:
  distributed_firewall:
    default_policy: "deny"
    application_rules: "whitelist"
    logging: "enabled"
  
  network_introspection:
    antivirus: "enabled"
    intrusion_detection: "enabled"
    file_integrity_monitoring: "enabled"
```

## Kubernetes Security

### Pod Security Standards

```yaml
# Pod Security Standards Configuration
apiVersion: v1
kind: Namespace
metadata:
  name: production-workloads
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
---
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
```

### RBAC Configuration

```yaml
# Cluster Role for Development Team
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dev-team-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dev-team-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dev-team-role
subjects:
- kind: Group
  name: dev-team
  apiGroup: rbac.authorization.k8s.io
```

### Network Policies

```yaml
# Default Deny Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Allow Frontend to Backend Communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## Container Security

### Image Security

```yaml
# Container Image Security Policy
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-signed-images
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: verify-signature
    match:
      resources:
        kinds:
        - Pod
    verifyImages:
    - imageReferences:
      - "*"
      attestors:
      - count: 1
        entries:
        - keys:
            publicKeys: |-
              -----BEGIN PUBLIC KEY-----
              MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...
              -----END PUBLIC KEY-----
```

### Runtime Security

```yaml
# Falco Configuration for Runtime Security
apiVersion: v1
kind: ConfigMap
metadata:
  name: falco-config
  namespace: falco
data:
  falco.yaml: |
    rules_file:
      - /etc/falco/falco_rules.yaml
      - /etc/falco/falco_rules.local.yaml
    
    time_format_iso_8601: true
    json_output: true
    json_include_output_property: true
    
    outputs:
      rate: 1
      max_burst: 1000
    
    syslog_output:
      enabled: true
    
    program_output:
      enabled: true
      keep_alive: false
      program: "curl -d @- -X POST http://falcosidekick:2801/"
```

## Network Security

### TLS Configuration

```yaml
# TLS Certificate Management
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@yourdomain.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tls-secret
  namespace: production
spec:
  secretName: tls-secret
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - api.yourdomain.com
  - app.yourdomain.com
```

### Service Mesh Security

```yaml
# Istio Security Configuration
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-frontend
  namespace: production
spec:
  selector:
    matchLabels:
      app: backend
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/frontend"]
    to:
    - operation:
        methods: ["GET", "POST"]
```

## Identity and Access Management

### OIDC Integration

```yaml
# OIDC Configuration for Kubernetes API Server
apiVersion: v1
kind: ConfigMap
metadata:
  name: oidc-config
  namespace: kube-system
data:
  oidc-issuer-url: "https://your-oidc-provider.com"
  oidc-client-id: "kubernetes"
  oidc-username-claim: "email"
  oidc-username-prefix: "oidc:"
  oidc-groups-claim: "groups"
  oidc-groups-prefix: "oidc:"
```

### Service Account Security

```yaml
# Service Account with Minimal Permissions
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: production
automountServiceAccountToken: false
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: production
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-rolebinding
  namespace: production
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-role
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: production
```

## Secrets Management

### External Secrets Operator

```yaml
# External Secrets Configuration
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-secret-store
  namespace: production
spec:
  provider:
    vault:
      server: "https://vault.yourdomain.com"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "external-secrets"
          serviceAccountRef:
            name: external-secrets-sa
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secret
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-secret-store
    kind: SecretStore
  target:
    name: app-secret
    creationPolicy: Owner
  data:
  - secretKey: database-password
    remoteRef:
      key: secret/data/database
      property: password
```

### Sealed Secrets

```yaml
# Sealed Secret Configuration
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: sealed-secret-example
  namespace: production
spec:
  encryptedData:
    password: AgBy3i4OJSWK+PiTySYZZA9rO43cGDEQAx...
  template:
    metadata:
      name: secret-example
      namespace: production
    type: Opaque
```

## Monitoring and Auditing

### Audit Logging

```yaml
# Kubernetes Audit Policy
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: None
  users: ["system:kube-proxy"]
  verbs: ["watch"]
  resources:
  - group: ""
    resources: ["endpoints", "services", "services/status"]
- level: None
  users: ["system:unsecured"]
  namespaces: ["kube-system"]
  verbs: ["get"]
  resources:
  - group: ""
    resources: ["configmaps"]
- level: None
  users: ["kubelet"]
  verbs: ["get"]
  resources:
  - group: ""
    resources: ["nodes", "nodes/status"]
- level: Request
  users: ["kubernetes-admin"]
  verbs: ["*"]
  resources:
  - group: ""
    resources: ["*"]
```

### Security Monitoring

```yaml
# Prometheus Security Alerting Rules
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: security-alerts
  namespace: monitoring
spec:
  groups:
  - name: security
    rules:
    - alert: UnauthorizedAPIAccess
      expr: increase(apiserver_audit_total{verb="create",objectRef_resource="pods/exec"}[5m]) > 0
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: "Unauthorized API access detected"
        description: "Pod exec command detected from user {{ $labels.user_username }}"
    
    - alert: PrivilegedContainerDetected
      expr: kube_pod_container_info{container_privileged="true"} > 0
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: "Privileged container detected"
        description: "Privileged container {{ $labels.container }} in pod {{ $labels.pod }}"
```

## Compliance and Governance

### Policy as Code

```yaml
# Gatekeeper Constraint Template
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        
        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Missing required label: %v", [missing])
        }
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: must-have-owner
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
  parameters:
    labels: ["owner", "environment"]
```

### Vulnerability Scanning

```yaml
# Trivy Operator Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: trivy-operator-config
  namespace: trivy-system
data:
  trivy.repository: "ghcr.io/aquasecurity/trivy"
  trivy.tag: "latest"
  trivy.severity: "CRITICAL,HIGH,MEDIUM"
  trivy.ignoreUnfixed: "false"
  trivy.timeout: "5m"
  trivy.resources.requests.cpu: "100m"
  trivy.resources.requests.memory: "100Mi"
  trivy.resources.limits.cpu: "500m"
  trivy.resources.limits.memory: "500Mi"
```

## Security Automation

### Continuous Security Scanning

```bash
#!/bin/bash
# security-scan.sh - Automated security scanning script

# Image vulnerability scanning
echo "Starting image vulnerability scan..."
trivy image --exit-code 0 --severity HIGH,CRITICAL myapp:latest

# Kubernetes configuration scanning
echo "Starting Kubernetes configuration scan..."
kube-score score deployment.yaml

# Network policy validation
echo "Validating network policies..."
kubectl apply --dry-run=client -f networkpolicies/

# RBAC analysis
echo "Analyzing RBAC permissions..."
kubectl auth can-i --list --as=system:serviceaccount:default:default

# Secret scanning
echo "Scanning for hardcoded secrets..."
git-secrets --scan

echo "Security scan completed!"
```

## Best Practices Summary

1. **Principle of Least Privilege**: Grant minimal necessary permissions
2. **Defense in Depth**: Implement multiple layers of security
3. **Zero Trust**: Never trust, always verify
4. **Continuous Monitoring**: Monitor and audit all activities
5. **Regular Updates**: Keep all components up to date
6. **Incident Response**: Have a plan for security incidents
7. **Education**: Train team members on security best practices
8. **Compliance**: Ensure adherence to relevant standards and regulations

## Security Checklist

- [ ] Enable Pod Security Standards
- [ ] Configure RBAC with minimal permissions
- [ ] Implement network policies
- [ ] Enable audit logging
- [ ] Configure TLS everywhere
- [ ] Implement secrets management
- [ ] Enable container image scanning
- [ ] Configure runtime security monitoring
- [ ] Implement backup and recovery
- [ ] Regular security assessments
- [ ] Incident response procedures
- [ ] Security awareness training

For detailed implementation of these security measures, refer to the specific configuration files in the repository's security directory.
