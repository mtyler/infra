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

provider "kubectl" {
  load_config_file  = true
  config_context    = var.context
}

provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = var.context
}

# Install the cert-manager helm chart
module "cert_manager" {
    count = var.cert_manager ? 1 : 0
    source = "./modules/cert-manager"
}

# Install the metrics-server helm chart
# cli: command = ["/metrics-server", "--cert-dir=/tmp", "--secure-port=10250", "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname", "--kubelet-use-node-status-port", "--metric-resolution=15s", "--kubelet-insecure-tls"]
resource "helm_release" "metrics_server" {
  count = var.metrics_server ? 1 : 0
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

module "initialize" {
    count = 1
    source = "./modules/initialize"
}

#module "rook_ceph" {
#    count = local.rook_ceph ? 1 : 0
#    source = "./modules/rook-ceph"
#    rook_ceph_cluster = var.rook_ceph_cluster
#}

module "ceph_cluster" {
    count = var.rook_ceph_cluster ? 1 : 0
    source = "./modules/ceph-cluster"
}

## Begin storage resources
#module "storage" {
#    # This module is meant to supprt storage type = nfs
#    # storage_type = local.storage_type == "nfs" ? 1 : 0
#    storage_type = local.storage_type
#    source = "./modules/storage"
#    nfs_share = local.nfs_share
#    nfs_server = local.nfs_server
#    depends_on = [ module.cert_manager ]
#}

module "gateway" {
    source = "./modules/gateway"
}

module "gateway-routes" {
    source = "./modules/gateway-routes"
    hostname = var.domain
    depends_on = [ module.gateway, module.monitoring, module.dashboard ]
}

module "dashboard" {
    count = var.dashboard ? 1 : 0
    source = "./modules/dashboard"
}

module "monitoring" {
    source = "./modules/monitoring"
    depends_on = [ module.dashboard, module.gateway]
#    storage_class_name = module.storage.storage_class_name
    slack_api_url = var.slack_api_url
    slack_channel = "#alertmanager"
}
