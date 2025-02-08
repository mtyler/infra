# Install the Rook Ceph Operator
locals {
  cluster_namespace = "rook-ceph-cluster"
  operator_namespace = "rook-ceph"
}


resource "helm_release" "rook-ceph-operator" {
  create_namespace = true
  namespace = local.operator_namespace
  name = "rook-ceph"
  repository = "https://charts.rook.io/release"
  chart = "rook-ceph"
  ## csi switches
  set {
    name = "csi.enableRbdDriver"
    value = "true"
  }
  set {
    name = "csi.enableCephfsDriver"
    value = "true"
  }
  set {
    name = "csi.disableCsiDriver"
    value = "false"
  }
  set {
    name = "csi.enableCSIHostNetwork"
    value = "true"
  }
  set {
    name = "csi.enableCephfsSnapshotter"
    value = "false"
  }
  set {
    name = "csi.enableNFSSnapshotter"
    value = "false"
  }
  set {
    name = "csi.enableRBDSnapshotter"
    value = "false"
  }
  set {
    name = "csi.provisionerReplicas"
    value = "1"
  }
  set {
    name = "enableDiscoveryDaemon"
    value = "true"
  }
  set {
    name = "discover.nodeAffinity"
    value = "node-cluster-role/storage="
  }
}

###
# 
#
### Install the Rook Ceph Cluster
resource "helm_release" "rook-ceph-cluster" {
  count = var.rook_ceph_cluster ? 1 : 0
  create_namespace = true
  namespace = local.cluster_namespace
  name = "rook-ceph-cluster"
  repository = "https://charts.rook.io/release"
  chart = "rook-ceph-cluster"
  set {
    name = "operatorNamespace"
    value = helm_release.rook-ceph-operator.namespace
  }
  set {
    # mon.count should be set to a min of 3 for production
    name = "cephClusterSpec.mon.count"
    value = "1"
  }
  set {
    # mgr.count should be set to 2 for production
    name = "cephClusterSpec.mgr.count"
    value = "1"
  }
  set {
    name = "cephClusterSpec.mgr.modules[0].name"
    value = "rook"
  }
  set {
    name = "cephClusterSpec.mgr.modules[0].enabled"
    value = "true"
  }
  set {
    name = "cephClusterSpec.dashboard.enabled"
    value = "true"
  }
  set {
    name = "cephClusterSpec.crashCollector.disable"
    value = "true"
  }
  ## 
  # cephClusterSpec.resources
  # chart defaults are:
  # resources:
  #   mgr:
  #     limits:
  #       memory: "1Gi"
  #     requests:
  #       cpu: "500m"
  #       memory: "512Mi"
  #   mon:
  #     limits:
  #       memory: "2Gi"
  #     requests:
  #       cpu: "1000m"
  #       memory: "1Gi"
  #   osd:
  #     limits:
  #       memory: "4Gi"
  #     requests:
  #       cpu: "1000m"
  #       memory: "4Gi"
  set {
    name = "cephClusterSpec.resources.mgr.limits.memory"
    value = "512Mi"
  }
  set {
    name = "cephClusterSpec.resources.mgr.requests.cpu"
    value = "250m"
  }
  set {
      name = "cephClusterSpec.resources.mgr.requests.memory"
      value = "256Mi"
  }
  set {
    name = "cephClusterSpec.resources.mon.limits.memory"
    value = "1Gi"
  }
  set {
    name = "cephClusterSpec.resources.mon.requests.cpu"
    value = "500m"
  }
  set {
    name = "cephClusterSpec.resources.mon.requests.memory"
    value = "512Mi"
  }
  set {
    name = "cephClusterSpec.resources.osd.limits.memory"
    value = "2Gi"
  }
  set {
    name = "cephClusterSpec.resources.osd.requests.cpu"
    value = "500m"
  }
  set {
    name = "cephClusterSpec.resources.osd.requests.memory"
    value = "2Gi"
  }
  # Config cephBlockPools
  set {
    name = "cephBlockPools[0].spec.replicated.size"
    value = "0"
  }
  set {
    name = "cephBlockPools[0].spec.replicated.requireSafeReplicaSize"
    value = "false"
  }
  set {
    name = "cephBlockPools[0].name"
    value = "ceph-blockpool"
  }
  set {
    name = "cephBlockPools[0].storageClass.enabled"
    value = "true"
  }
  set {
    name = "cephBlockPools[0].storageClass.name"
    value = "ceph-block"
  }
###  set {
###    name = "cephBlockPools[0].storageClass.isDefault"
###    value = "true"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.reclaimPolicy"
###    value = "Delete"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.allowVolumeExpansion"
###    value = "true"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.volumeBindingMode"
###    value = "Immediate"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.imageFormat"
###    value = "2"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.imageFeatures"
###    value = "layering"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.csi.storage.k8s.io/provisioner-secret-name"
###    value = "rook-csi-rbd-provisioner"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.csi.storage.k8s.io/provisioner-secret-namespace"
###    value = local.cluster_namespace
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.csi.storage.k8s.io/controller-expand-secret-name"
###    value = "rook-csi-rbd-provisioner"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.csi.storage.k8s.io/controller-expand-secret-namespace"
###    value = local.cluster_namespace
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.csi.storage.k8s.io/node-stage-secret-name"
###    value = "rook-csi-rbd-node"
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.csi.storage.k8s.io/node-stage-secret-namespace"
###    value = local.cluster_namespace
###  }
###  set {
###    name = "cephBlockPools[0].storageClass.parameters.csi.storage.k8s.io/fstype"
###    value = "ext4"
###  }
  # Config cephFilesystems
  set {
    name = "cephFilesystems[0].spec.metadataPool.replicated.size"
    value = "1"
  }
#  set {
#    name = "cephObjectStores[0].spec.metadataPool.replicated.size"
#    value = "0"
#  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = [ helm_release.rook-ceph-operator ]
}

#data "helm_release" "rook-ceph-cluster" {
#  count = var.rook_ceph_cluster ? 1 : 0
#  metadata {
#    name = "rook-ceph-cluster"
#    namespace = "rook-ceph-cluster"
#  }
#}

#output "cephbp_storage_class_name" {
#    value = helm_release.rook-ceph-cluster.status
#}
#
#output "cephfs_storage_class_name" {
#    value = helm_release.rook-ceph-cluster.status
#}
