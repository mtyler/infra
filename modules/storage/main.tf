resource "kubernetes_namespace" "storage" {
  metadata {
    name = var.namespace
  }
}
# this script will set up the storage namespace, storage class 
# and anything else required for Dynamic Provisioning
#
# There are a couple of options for storage:
# 1. NFS
# 2. Local Path Provisioner
# 3. TopoLVM

# Install the NFS CSI Driver
resource "helm_release" "csi-driver-nfs" {
  count      = var.storage_type == "nfs" ? 1 : 0
  name       = "csi-driver-nfs"
  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  namespace  = var.namespace
  version    = "v4.10.0"
  set {
    name = "externalSnapshotter.enabled"
    value = "true"
  }
  #set {
  #  name = "controller.runOnControlPlane"
  #  value = "true"
  #}
  #set {
  #  name = "controller.replicas"
  #  value = "2"
  #}
  # Storage Class Settings
  set {
    name = "storageClass.create"
    value = "true"
  }
  set {
    name = "storageClass.name"
    value = var.storage_class_name
  }
  set {
    name = "storageClass.parameters.server"
    value = var.nfs_server
  }
  set {
    name = "storageClass.parameters.share"
    value = var.nfs_share
#    value = "/nfs/k8s-cluster-pvs"
  }
  set {
    name = "storageClass.mount_options"
    value = "['nfsver=4.1']"
  }
  set {
    name = "storageClass.volumeBindingMode"
    value = "WaitForFirstConsumer"
  }
  depends_on = [ kubernetes_namespace.storage ]
}

# update the default storage class to the new NFS storage class
resource "kubernetes_annotations" "csi-driver-nfs-storage-class" {
  count = var.storage_type == "nfs" ? 1 : 0
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = var.storage_class_name
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "true"
  }
  depends_on = [ helm_release.csi-driver-nfs ]
}

resource "helm_release" "topolvm" {
  count = var.storage_type == "topolvm" ? 1 : 0
  namespace = var.namespace
  name = "topolvm"
  repository = "https://topolvm.github.io/topolvm"
  chart = "topolvm"
  set {
    name = "controller.replicaCount"
    value = "1"
  }
  set {
    name = "lmvd.volumes[0].name"
    value = "lvmd-dir"
  }
  set {
    name = "lmvd.volumes[0].hostPath.path"
    value = "/storage/topolvmd"
  }
  set {
    name = "lmvd.volumes[0].hostPath.type"
    value = "DirectoryOrCreate"
  }
  set {
    name = "lmvd.volumeMounts[0].name"
    value = "lvmd-dir"
  }
  set {
    name = "lmvd.volumeMounts[0].mountPath"
    value = "/topolvm"
  }
}

resource "kubernetes_labels" "topolvm" {
  count = var.storage_type == "toplvm" ? 1 : 0
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = var.namespace
  }
  labels = {
    "topolvm.io/webhook" = "ignore"
  }
}

resource "helm_release" "local-path-provisioner" {
  count = var.storage_type == "lpp" ? 1 : 0
  create_namespace = true
  namespace = var.namespace
  name = "local-path-provisioner"
  repository = "https://github.com/rancher/local-path-provisioner"
  chart = "deploy/chart/local-path-provisioner"
  set {
    
    name = "nodePathMap[0].paths[0]"
    value = "/storage"
  }
  
}