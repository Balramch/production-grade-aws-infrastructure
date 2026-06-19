settings:
  clusterName: ${cluster_name}
  interruptionQueue: ${interruption_queue}

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${controller_role_arn}

controller:
  resources:
    requests:
      cpu: 1
      memory: 1Gi
    limits:
      cpu: 1
      memory: 1Gi
%{ if length(node_affinity_nodegroups) > 0 }
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: karpenter.sh/nodepool
            operator: DoesNotExist
          - key: eks.amazonaws.com/nodegroup
            operator: In
            values:
%{ for ng in node_affinity_nodegroups }
            - ${ng}
%{ endfor }
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"
%{ endif }
