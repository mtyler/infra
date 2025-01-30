resource "kubernetes_namespace" "storage" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "csi-driver-nfs" {
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
