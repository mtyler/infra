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

###locals {
###  user = "vagrant@cp2"
###  pki_dir = "/etc/kubernetes/pki/etcd"
###}
###
###data "external" "etcd_client_ca_crt" {
###  program = ["sh", "-c", "ssh ${local.user} 'cat ${local.pki_dir}/etcd-client-ca.crt'"]
###}
###
###data "external" "etcd_client_crt" {
###  program = ["sh", "-c", "ssh ${local.user} 'cat ${local.pki_dir}/etcd-client.crt'"]
###}
###
###data "external" "etcd_client_key" {
###  program = ["sh", "-c", "ssh ${local.user} 'cat ${local.pki_dir}/etcd-client.key'"]
###}
###
###resource "kubernetes_secret" "etcd-certs" {
###  metadata {
###    name      = "etcd-certs"
###    namespace = "monitoring"
###  }
###  data = {
###    "etcd-client-ca.crt" = data.external.etcd_client_ca_crt.result["output"]
###    "etcd-client.crt"    = data.external.etcd_client_crt.result["output"]
###    "etcd-client.key"    = data.external.etcd_client_key.result["output"]
###  }
###}
