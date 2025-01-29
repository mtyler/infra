
locals {
  namespace = "monitoring"
}

#resource "kubernetes_persistent_volume" "security_pv" {
#  metadata {
#    name = "security-pv"
#    labels = {
#      "app.kubernetes.io/component" = "ui-redis"
#      "app.kubernetes.io/instance" = "falcosecurity"
#      "app.kubernetes.io/name" = "falcosidekick"
#    }  
#  }
#  spec {
#    capacity = {
#      storage = "1Gi"
#    }
#    volume_mode = "Filesystem"
#    persistent_volume_source {
#        local {
#            path = "/var/local"
#        }
#    }
#    access_modes = ["ReadWriteOnce"]
#    persistent_volume_reclaim_policy = "Retain"
#    storage_class_name = "local-storage"
#  }
#}

resource "helm_release" "falco" {
  create_namespace = true
  name       = "falcosecurity"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  namespace  = local.namespace
  set {
    name = "driver.kind"
    value = "modern_ebpf"
  }
  set {
    name = "tty"
    value = "true"
  }
  set {
    name = "metrics.enabled"
    value = "true"
  }
  set {
    name = "serviceMonitor.create"
    value = "true"
  }
  set {
    name = "grafana.dashboards.enabled"
    value = "true"
  }
  set {
    name = "grafana.dashboards.configMaps.falco.namespace"
    value = "monitoring"
  }
  set {
    name = "grafana.dashboards.configMaps.falco.folder"
    value = "security"
  }
  set {
    name = "falcosidekick.enabled"
    value = "true"
  }
#  set {
#    name = "falcosidekick.webui.enabled"
#    value = "true"
#  }

}