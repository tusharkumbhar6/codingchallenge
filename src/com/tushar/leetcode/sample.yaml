# Tenant-specific values for Tenant1 - UAT Environment
# This file overrides the base values.yaml from manifest/openvscode-server/

# Tenant identification
tenant:
  name: "tenant1"
  namespace: "openvscode-tenant1"

# Use your custom image with Python and Jupyter extensions
image:
  registry: ""  # Leave empty if using Docker Hub, or specify: "your-registry.io"
  repository: "your-company/openvscode-server"
  tag: "1.0.0-python-jupyter"
  pullPolicy: IfNotPresent

imagePullSecrets: []
# - name: registry-credentials

# Replicas - Start with 3 for 40-100 users
replicaCount: 3

# Service Account
serviceAccount:
  create: true
  annotations: {}
  name: ""

# Horizontal Pod Autoscaler
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 15
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 65
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 75

# Resource limits - Adjust based on your workload
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 500m
    memory: 1Gi

# Service configuration
service:
  type: ClusterIP
  port: 3000
  targetPort: 3000
  annotations: {}
    # For monitoring
    # prometheus.io/scrape: "true"
    # prometheus.io/port: "3000"

# Ingress configuration
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    # WebSocket support
    nginx.ingress.kubernetes.io/websocket-services: "openvscode-tenant1"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
  hosts:
    - host: vscode-tenant1-uat.yourcompany.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: openvscode-tenant1-uat-tls
      hosts:
        - vscode-tenant1-uat.yourcompany.com

# Persistent storage - IMPORTANT: Use ReadWriteMany for multi-pod
persistence:
  enabled: true
  storageClassName: "nfs-client"  # Replace with your RWX storage class
  accessModes:
    - ReadWriteMany
  size: 100Gi
  annotations: {}
  # Optional: Use existing PVC
  # existingClaim: "existing-pvc-name"

# OpenVSCode Server configuration
openvscode:
  # Connection token (optional, for authentication)
  # Leave empty to generate random token
  connectionToken: ""
  
  # Server arguments
  args:
    - "--host=0.0.0.0"
    - "--port=3000"
    # Choose one authentication method:
    - "--without-connection-token"  # No auth (use with SSO/VPN)
    # OR
    # - "--connection-token-file=/etc/openvscode/token"  # Token-based auth
  
  # Environment variables
  env:
    - name: OPENVSCODE_SERVER_ROOT
      value: "/home/workspace"
    - name: DEFAULT_WORKSPACE
      value: "/home/workspace"
    - name: TENANT_NAME
      value: "tenant1"
    - name: ENVIRONMENT
      value: "uat"
    - name: LOG_LEVEL
      value: "info"
    # Python-specific
    - name: PYTHON_VERSION
      value: "3.11"
    - name: JUPYTER_ENABLE_LAB
      value: "yes"
  
  # VS Code extensions to pre-install (if not in your image)
  extensions: []
    # - "ms-python.python"
    # - "ms-toolsai.jupyter"
    # - "ms-python.vscode-pylance"
  
  # User settings (settings.json)
  settings:
    workbench.colorTheme: "Default Dark+"
    python.defaultInterpreterPath: "/usr/bin/python3"
    jupyter.askForKernelRestart: false
    files.autoSave: "afterDelay"
    editor.fontSize: 14
    terminal.integrated.defaultProfile.linux: "bash"
    files.watcherExclude:
      "**/.git/objects/**": true
      "**/.git/subtree-cache/**": true
      "**/node_modules/**": true

# ConfigMap for additional configurations
configMap:
  enabled: true
  data: {}
    # Add any additional config files here
    # custom-config.json: |
    #   {"key": "value"}

# Secret for sensitive data
secret:
  enabled: true
  type: Opaque
  data: {}
    # Add base64 encoded secrets here
    # Example: token: "base64-encoded-value"

# Security Context
podSecurityContext:
  fsGroup: 1000
  runAsUser: 1000
  runAsNonRoot: true

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  runAsUser: 1000

# Liveness and Readiness Probes
livenessProbe:
  httpGet:
    path: /healthz
    port: 3000
    scheme: HTTP
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /healthz
    port: 3000
    scheme: HTTP
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3

# Startup Probe (for slow-starting containers)
startupProbe:
  httpGet:
    path: /healthz
    port: 3000
  initialDelaySeconds: 0
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 30  # 30 * 5s = 150s max startup time

# Node selection and affinity
nodeSelector: {}
  # Example: workload: openvscode

tolerations: []

# Pod anti-affinity to spread pods across nodes
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - openvscode-server
              - key: tenant
                operator: In
                values:
                  - tenant1
          topologyKey: kubernetes.io/hostname
  # Optional: Node affinity for specific node pools
  # nodeAffinity:
  #   requiredDuringSchedulingIgnoredDuringExecution:
  #     nodeSelectorTerms:
  #       - matchExpressions:
  #           - key: node-role.kubernetes.io/worker
  #             operator: In
  #             values:
  #               - "true"

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 2
  # OR use maxUnavailable instead:
  # maxUnavailable: 1

# Additional labels for all resources
commonLabels:
  tenant: tenant1
  environment: uat
  team: tenant1-team
  app: openvscode-server

# Pod-specific labels
podLabels:
  tenant: tenant1
  version: v1.0.0

# Pod-specific annotations
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "3000"

# Lifecycle hooks
lifecycle: {}
  # preStop:
  #   exec:
  #     command: ["/bin/sh", "-c", "sleep 15"]

# Init containers (if needed)
initContainers: []
  # - name: init-workspace
  #   image: busybox:1.35
  #   command: ['sh', '-c', 'mkdir -p /workspace/users && chown -R 1000:1000 /workspace']
  #   volumeMounts:
  #     - name: workspace
  #       mountPath: /workspace

# Additional volumes
extraVolumes: []
  # - name: custom-config
  #   configMap:
  #     name: custom-configmap

# Additional volume mounts
extraVolumeMounts: []
  # - name: custom-config
  #   mountPath: /etc/custom

# Priority class (optional)
priorityClassName: ""

# Topology Spread Constraints (for better distribution)
topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: topology.kubernetes.io/zone
  #   whenUnsatisfiable: ScheduleAnyway
  #   labelSelector:
  #     matchLabels:
  #       app.kubernetes.io/name: openvscode-server
