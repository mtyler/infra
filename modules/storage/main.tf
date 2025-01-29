locals {
  namespace = "storage"
}

resource "kubernetes_namespace" "storage" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "csi-driver-nfs" {
  name       = "csi-driver-nfs"
  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  namespace  = local.namespace
  version    = "v4.10.0"
  set {
    name = "externalSnapshotter.enabled"
    value = "true"
  }
  set {
    name = "controller.runOnControlPlane"
    value = "true"
  }
  set {
    name = "controller.replicas"
    value = "2"
  }
##  set {
##    name = "storageClass.create"
##    value = "true"
##  }
##  set {
##    name = "storageClass.name"
##    value = "csi-nfs"
##  }

  depends_on = [ kubernetes_namespace.storage ]
}

resource "kubernetes_storage_class" "csi-nfs" {
  metadata {
    name = "csi-nfs"
  }
  parameters = {
    server = "10.0.0.11"
    share  = "/var/nfs/k8s-cluster"
    subDir = ""
    mountPermissions: "0"
  }
  storage_provisioner = "nfs.csi.k8s.io"
  reclaim_policy = "Retain"
  volume_binding_mode = "Immediate"
  mount_options = ["nfsvers=4.1"]
  allow_volume_expansion = "true"
  depends_on = [ helm_release.csi-driver-nfs ]
}

#resource "kubernetes_persistent_volume" "csi-nfs-pv" {
#  metadata {
#    name = "csi-nfs-pv"
#  }
#  spec {
#    capacity = "10Gi"
#    access_modes = [ "ReadWriteMany" ]
#    persistent_volume_reclaim_policy = "Retain"
#    persistent_volume_source {
#      csi {
#        driver = "nfs.csi.k8s.io"
#        # volumeHandle format: {nfs-server-address}#{sub-dir-name}#{share-name}
#        # make sure this value is unique for every share in the cluster
#        volume_handle = "10.0.0.11/var/nfs/k8s-cluster"
#        volume_attributes = {
#          server = "10.0.0.11"
#          share = "/var/nfs/k8s-cluster"
#        }
#      }
#    } 
#    storage_class_name = "csi-nfs"
#    mount_options = [ "nfsvers=4.1" ]
#  }
#}