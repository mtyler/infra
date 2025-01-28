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
  storage_provisioner = "kubernetes.io/no-provisioner"
  reclaim_policy = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  mount_options = ["nfsvers=4.1"]
  depends_on = [ helm_release.csi-driver-nfs ]
}