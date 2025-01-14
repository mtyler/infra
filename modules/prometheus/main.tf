# create a prometheus server
resource "kubernetes_storage_class" "local-storage" {
  metadata {
    name = "local-storage"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  reclaim_policy = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "helm_release" "prometheus" {
  create_namespace = true
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  set {
    name  = "server.persistentVolume.storageClass"
    value = resource.kubernetes_storage_class.local-storage.metadata[0].name
    # local-storage <= k8s, standard <= kind
  }
  set {
    name  = "server.persistentVolume.spec.hostPath.path"
    value = "/usr/data"
  }
  set {
    name  = "server.persistentVolume.size"
    value = "1Gi"
  } 
}
