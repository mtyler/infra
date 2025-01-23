
locals {
  namespace = "logging"
}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_persistent_volume_claim" "local-pvc" {
  metadata {
    name = "local-pvc"
    namespace = local.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "local-storage"
  }
  depends_on = [ kubernetes_namespace.logging ]
}

resource "helm_release" "loki" {
  create_namespace = true
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = local.namespace
  set {
    name  = "grafana.enabled"
    value = "true"
  }
#  set {
#    name  = "loki.persistence.enabled"
#    value = "true"
#  }
#  set {
#    name  = "loki.persistence.size"
#    value = "10Gi"
#  }
#  set {
#    name  = "loki.persistence.storageClassName"
#    value = var.storage_class
#  }
  depends_on = [ kubernetes_namespace.logging ] 
}