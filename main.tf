terraform {
    required_version = ">= 0.13"

}

provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = var.context
}

module "gateway" {
    source = "./modules/gateway"
    context = var.context
}

module "dashboard" {
    source = "./modules/dashboard"
}

module "prometheus" {
    source = "./modules/prometheus"
}

module "cafe" {
    source = "./modules/apps/cafe"
    context = var.context  
}