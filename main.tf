terraform {
    required_version = ">= 0.13"
    required_providers {
      kubernetes = {
        source = "hashicorp/kubernetes"
        version = ">=2.35.1"
      }
    }
}

provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = var.context
}

#resource "kubernetes_storage_class" "local-storage" {
#  metadata {
#    name = "local-storage"
#  }
#  storage_provisioner = "kubernetes.io/no-provisioner"
#  reclaim_policy = "Retain"
#  volume_binding_mode = "WaitForFirstConsumer"
#}

module "gateway" {
    source = "./modules/gateway"
    context = var.context
}

module "httproutes" {
    source = "./modules/httproutes"
    context = var.context
    hostname = var.domain
    depends_on = [ module.gateway, module.monitoring, module.dashboard ]
}

module "storage" {
    source = "./modules/storage"
}

module "dashboard" {
    source = "./modules/dashboard"
    depends_on = [ module.gateway ]
}

module "monitoring" {
    source = "./modules/monitoring"
    depends_on = [ module.dashboard, module.gateway ]
#    storage_class = kubernetes_storage_class.local-storage.metadata[0].name
    storage_class = module.storage.storage_class
    slack_api_url = var.slack_api_url
}

module "logging" {
    source = "./modules/logging"
    depends_on = [ module.dashboard, module.gateway ]
}

#module "security" {
#    source = "./modules/security"
#    depends_on = [ module.dashboard, module.gateway ]
#}

#module "kubescape" {
#    source = "./modules/kubescape"
#    storage_class = module.storage.storage_class
#    depends_on = [ module.storage, module.dashboard, module.gateway ]
#}

