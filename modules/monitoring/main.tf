# create a prometheus server
resource "helm_release" "prometheus" {
  create_namespace = true
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace
  
  # uncomment to enable persistent volume using storage class
  # !! currently failing when trying to chown the shared volume
  # !! need to investigate further
  ##set {
  ##  name  = "grafana.persistence.enabled"
  ##  value = "true"
  ##}
  ##set {
  ##  name  = "grafana.persistence.storageClassName"
  ##  value = var.storage_class_name
  ##}

  # uncomment to enable persistent volume on hostpath
  ##set {
  ##  name  = "server.persistentVolume.storageClass"
  ##  value = var.storage_class_name
  ##  # local-storage <= k8s, standard <= kind
  ##}
  ##set {
  ##  name  = "server.persistentVolume.spec.hostPath.path"
  ##  value = "/usr/data"
  ##}
  ##set {
  ##  name  = "server.persistentVolume.size"
  ##  value = "1Gi"
  ##}
  set {
    name =  "alertmanager.config.receivers[0].name"
    value = "slack"
  }
  set {
    name =  "alertmanager.config.receivers[0].slack_configs[0].channel"
    value = "#alertmanager"
  } 
  set {
    name =  "alertmanager.config.receivers[0].slack_configs[0].api_url"
    value = var.slack_api_url
  }
  set {
    name = "alertmanager.config.receivers[0].slack_configs[0].send_resolved"
    value = "true"
  }
  set {
    name = "alertmanager.config.route.receiver"
    value = "slack"
  }
  set {
    name = "alertmanager.config.route.routes[0].receiver"
    value = "slack"
  }
  set {
    name = "alertmanager.config.route.routes[0].matchers[0]"
    value = "alertname = Watchdog"
  }
  set {
    name = "kubeEtcd.enabled"
    value = "true"
  }
  set {
    name = "kubeEtcd.service.enabled"
    value = "true"
  }
  set {
    name = "kubeEtcd.service.port"
    value = "2381"
  }
  set {
    name = "kubeEtcd.service.targetPort"
    value = "2381"
  }
}

#resource "kubernetes_persistent_volume" "testing-pv" {
#  metadata {
#    name = "testing-pv"
#  }
#  spec {
#    capacity = {
#      storage = "1Gi"
#    }
#    volume_mode = "Filesystem"
#    persistent_volume_source {
#        # TODO get path dynamically/pass in
#        local {
#            path = "/nfs/k8s-cluster-pvs"
#        }
#    }
#    access_modes = ["ReadWriteOnce"]
#    persistent_volume_reclaim_policy = "Retain"
#    storage_class_name = var.storage_class
#  }
#}

resource "helm_release" "falco" {
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  name       = "falcosecurity"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  namespace  = var.namespace
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
    name = "collectors.kubernetes.enabled"
    value = "true"
  }
  # grafana settings
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
  # falcosidekick
  set {
    name = "falcosidekick.enabled"
    value = "true"
  }
  set {
    name = "falcosidekick.webui.enabled"
    value = "true"
  }
  set {
    name = "falcosidekick.webui.redis.storageClass"
    value = var.storage_class_name
  }
  set {
    name = "falcosidekick.grafana.enabled"
    value = "true"
  }
  set {
    name = "falcosidekick.grafana.dashboard.enabled"
    value = "true"
  }
  set {
    name = "falcosidekick.prometheusRules.enabled"
    value = "true"
  }
  set {
    name = "falcosidekick.config.slack.webhookurl"
    value = var.slack_api_url
  }
#  depends_on = [ kubernetes_persistent_volume.monitoring-pv ]
}

#resource "helm_release" "jaegertracing" {
#  create_namespace = true
#  name       = "jaegertracing"
#  repository = "https://jaegertracing.github.io/helm-charts"
#  chart      = "jaegertracing"
#  namespace  = local.namespace
#  
#}