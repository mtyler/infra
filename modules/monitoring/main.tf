# create a prometheus server
locals {
  namespace = "monitoring"
}

resource "helm_release" "prometheus" {
  create_namespace = true
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = local.namespace
  set {
    name  = "server.persistentVolume.storageClass"
    value = var.storage_class
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
    #TODO get this from a secure source
    value = "https://hooks.slack.com/services/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"
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
}
