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

module "storage" {
    source = "./modules/storage"
    nfs_share = local.nfs_share
    nfs_server = local.nfs_server
}

module "gateway" {
    source = "./modules/gateway"
}

module "gateway-routes" {
    source = "./modules/gateway-routes"
    hostname = var.domain
    depends_on = [ module.gateway, module.monitoring, module.dashboard ]
}

module "dashboard" {
    source = "./modules/dashboard"
    depends_on = [ module.gateway ]
}

module "monitoring" {
    source = "./modules/monitoring"
    depends_on = [ module.dashboard, module.gateway, module.storage ]
    storage_class_name = module.storage.storage_class_name
    slack_api_url = var.slack_api_url
    slack_channel = "#alertmanager"
}
