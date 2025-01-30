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

resource "helm_release" "falco" {
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  name       = "falcosecurity"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  namespace  = var.namespace
  set {
    name = "driver.enabled"
    value = "false"
  }
  set {
    name = "collecotors.enabled"
    value = "false"
  }
  set {
    name = "controller.kind"
    value = "deployment"
  }
  set {
    name = "controller.deployment.replicas"
    value = "1"
  }
  set {
    name = "falcoctl.artifact.install.enabled"
    value = "true"
  }
  set {
    name = "falcoctl.artifact.follow.enabled"
    value = "true"
  }
  set {
    name = "falcoctl.config.artifact.install.refs[0]"
    value = "k8saudit-rules:0.11"
  }
  set {
    name = "falcoctl.config.artifact.install.refs[1]"
    value = "k8saudit:0.11"
  }
  set {
    name = "falcoctl.config.artifact.follow.refs[0]"
    value = "k8saudit-rules:0.11"
  }
  set {
    name = "services[0].name"
    value = "k8saudit-webhook"
  }
  set {
    name = "services[0].type"
    value = "NodePort"
  }
  set {
    name = "services[0].ports[0].port"
    value = "9765"
  }
  set {
    name = "services[0].ports[0].nodePort"
    value = "30007"
  }
  set {
    name = "services[0].ports[0].protocol"
    value = "TCP"
  }
  set {
    name = "falco.rules_files[0]"
    value = "/etc/falco/k8s_audit_rules.yaml"
  }
  set {
    name = "falco.rules_files[1]"
    value = "/etc/falco/rules.d"
  }
  set {
    name = "falco.plugins[0].name"
    value = "k8saudit"
  }
  set {
    name = "falco.plugins[0].library_path"
    value = "libk8saudit.so"
  }
  set {
    name = "falco.plugins[0].lib_config"
    value = "''"
  }
  set {
    name = "falco.plugins[0].open_params"
    value = "http://:9765/k8s-audit"
  }
  set {
    name = "falco.plugins[1].name"
    value = "json"
  }
  set {
    name = "falco.plugins[1].library_path"
    value = "libjson.so"
  }
  set {
    name = "falco.plugins[1].init_config"
    value = ""
  }
  set {
    name = "falco.load_plugins[0]"
    value = "k8saudit"
  }
    set {
    name = "falco.load_plugins[1]"
    value = "json"
  }
  # uncomment to enable real-time detection/alerting
  #set {
  #  name = "tty"
  #  value = "true"
  #}
  set {
    name = "metrics.enabled"
    value = "true"
  }
  set {
    name = "serviceMonitor.create"
    value = "true"
  }
  # enables the k8smetacollector plugin
  set {
    name = "collectors.enabled"
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
  #set {
  #  name = "grafana.dashboards.configMaps.falco.namespace"
  #  value = "monitoring"
  #}
  #set {
  #  name = "grafana.dashboards.configMaps.falco.folder"
  #  value = "security"
  #}
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

#resource "helm_release" "falco-k8s-metacollector" {
#  create_namespace = true
#  atomic           = true
#  cleanup_on_fail  = true
#  name       = "k8s-metacollector"
#  repository = "https://falcosecurity.github.io/charts"
#  chart      = "k8s-metacollector"
#  namespace = var.namespace
#  set {
#    name = "serviceMonitor.create"
#    value = "true"
#  }
#  set {
#    name = "serviceMonitor.labels.release"
#    value = "kube-prometheus-stack"
#  }
#  set {
#    name = "grafana.dashboards.enabled"
#    value = "true"
#  }
#}

#resource "helm_release" "jaegertracing" {
#  create_namespace = true
#  name       = "jaegertracing"
#  repository = "https://jaegertracing.github.io/helm-charts"
#  chart      = "jaegertracing"
#  namespace  = local.namespace
#  
#}