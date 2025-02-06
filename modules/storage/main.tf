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

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name      = "selfsigned-root"
    }
    spec = {
      selfSigned = {}
    }
  }
#  depends_on = [ helm_release.cert_manager ]
}


# Install the Rook Ceph Operator
resource "helm_release" "rook-ceph-operator" {
  count = var.storage_type == "rook-ceph" ? 1 : 0
  create_namespace = true
  namespace = var.namespace
  name = "rook-ceph"
  repository = "https://charts.rook.io/release"
  chart = "rook-ceph"
  set {
    name = "enableDiscoveryDaemon"
    value = "true"
  }
}

resource "helm_release" "rook-ceph-cluster" {
  count = var.storage_type == "rook-ceph" ? 1 : 0
  namespace = var.namespace
  name = "rook-ceph-cluster"
  repository = "https://charts.rook.io/release"
  chart = "rook-ceph-cluster"
  set {
    name = "operatorNamespace"
    value = var.namespace
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
    # turn off Block Pools 
    name = "cephBlockPools[0]"
    value = ""
  }
  set {
    # turn off CephFS
    name = "cephFilesystems[0]"
    value = ""
  }

}


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



#resource "helm_release" "minio-operator" {
#  count = var.storage_type == "minio" ? 1 : 0
#  create_namespace = true
#  name       = "minio-operator"
#  repository = "https://operator.min.io/"
#  chart      = "operator"
#  namespace  = var.namespace
#  set {
#    name = "tenant.pools[0].servers"
#    value = "1"
#  }
#  set {
#    name = "tenant.pools[0].name"
#    value = "pool0"
#  }
#  set {
#    name = "tenant.pools[0].volumesPerServer"
#    value = "4"
#  }
#  set {
#    name = "tenant.pools[0].size"
#    value = "10Gi"
#  }
#  set {
#    name = "tenant.pools[0].storageClassName"
#    value = "directpv-min-io"
#  }
#}

#resource "helm_release" "minio-tenant" {
#  count = var.storage_type == "minio" ? 1 : 0
#  create_namespace = true
#  name       = "minio-tenant"
#  repository = "https://operator.min.io/"
#  chart      = "tenant"
#  namespace  = "${var.namespace}-tenant"
#  depends_on = [helm_release.minio-operator]
#}