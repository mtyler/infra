
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
    name  = "grafana.enabled"
    value = "false"
  }
  set {
    name  = "fluentbit.enabled"
    value = "true"
  }
  set {
    name  = "promtail.enabled"
    value = "false"
  }
}