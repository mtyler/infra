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

module "gateway" {
    count = 1
    source = "./modules/gateway"
}

# Install the cert-manager helm chart
module "cert_manager" {
    count = var.cert_manager_enabled ? 1 : 0
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

module "rook_ceph" {
    count = var.rook_ceph ? 1 : 0
    source = "./modules/rook-ceph"
    rook_ceph_cluster = var.rook_ceph_cluster
    rook_ceph_cluster_nohelm = var.rook_ceph_cluster_nohelm
}

module "gateway-routes" {
    count = var.dashboard && var.monitoring ? 1 : 0
    source = "./modules/gateway-routes"
    hostname = var.domain
    depends_on = [ module.gateway, module.monitoring, module.dashboard ]
}

module "dashboard" {
    count = var.dashboard ? 1 : 0
    source = "./modules/dashboard"
}

module "monitoring" {
    count = var.monitoring ? 1 : 0
    source = "./modules/monitoring"
    depends_on = [ module.dashboard, module.gateway]
    storage_class_name = "rook-ceph-block" #module.rook_ceph.cephbp_storage_class_name
    slack_api_url = var.slack_api_url
    slack_channel = "#alertmanager"
    falco_enabled = true
}
