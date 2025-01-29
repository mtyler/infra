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

module "storage" {
    source = "./modules/storage"
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
    depends_on = [ module.dashboard, module.gateway ]
#    storage_class = kubernetes_storage_class.local-storage.metadata[0].name
    storage_class = module.storage.storage_class
    slack_api_url = var.slack_api_url
}

module "security" {
    source = "./modules/security"
    depends_on = [ module.dashboard, module.gateway ]
}

