
locals {
  namespace = "logging"
}

resource "helm_release" "loki" {
  create_namespace = true
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = local.namespace
  set {
    name  = "loki.persistence.enabled"
    value = "true"
  }
  set {
    name  = "loki.persistence.size"
    value = "1Gi"
  }
  set {
    name  = "loki.persistence.storageClassName"
    value = var.storage_class
  }
  
}