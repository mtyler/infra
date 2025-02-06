terraform {
    required_version = ">= 0.13"
    
    required_providers {
      kubectl = {
        source = "gavinbunney/kubectl"
        version = ">=1.19.0"
      }
      helm = {
        source = "hashicorp/helm"
        version = ">=2.17.0"
      }
      kubernetes = {
        source = "hashicorp/kubernetes"
        version = ">=2.35.1"
      }
      http = {
        source = "hashicorp/http"
      }
    }
}

locals {
    # strorage_type options: nfs, local-path, topolvm
    storage_type      = "rook-ceph"
    nfs_share         = "/nfs/k8s-cluster-pvs"
    nfs_server        = "10.0.0.11"
}

provider "kubectl" {
  load_config_file  = true
  config_context    = var.context
}

provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = var.context
}

resource "kubernetes_storage_class" "local_path" {
  # This resource is only created if the storage type is local-path
  count = local.storage_type == "local-path" ? 1 : 0
  metadata {
    name = "local-path"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  reclaim_policy = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}

# Install the metrics-server helm chart
# cli: command = ["/metrics-server", "--cert-dir=/tmp", "--secure-port=10250", "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname", "--kubelet-use-node-status-port", "--metric-resolution=15s", "--kubelet-insecure-tls"]
resource "helm_release" "metrics_server" {
  namespace = "kube-system"
  chart = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  name = "metrics-server"
  set {
    name = "metrics.enabled"
    value = "true"
  }
  set {
    name = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}

module "storage" {
    # This module is meant to supprt storage type = nfs
#    storage_type = local.storage_type == "nfs" ? 1 : 0
    storage_type = local.storage_type
    source = "./modules/storage"
    nfs_share = local.nfs_share
    nfs_server = local.nfs_server
    depends_on = [ module.cert_manager ]
}

module "gateway" {
    source = "./modules/gateway"
}

module "cert_manager" {
    source = "./modules/cert-manager"
}

#module "gateway-routes" {
#    source = "./modules/gateway-routes"
#    hostname = var.domain
#    depends_on = [ module.gateway, module.monitoring, module.dashboard ]
#}

#module "dashboard" {
#    source = "./modules/dashboard"
#    depends_on = [ module.gateway ]
#}

#module "monitoring" {
#    source = "./modules/monitoring"
#    depends_on = [ module.dashboard, module.gateway, module.storage ]
#    storage_class_name = module.storage.storage_class_name
#    slack_api_url = var.slack_api_url
#    slack_channel = "#alertmanager"
#}
