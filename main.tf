terraform {
    required_version = ">= 0.13"

}

provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = var.context
}

resource "kubernetes_storage_class" "local-storage" {
  metadata {
    name = "local-storage"
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  reclaim_policy = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
}

module "gateway" {
    source = "./modules/gateway"
    context = var.context
}

module "dashboard" {
    source = "./modules/dashboard"
    depends_on = [ module.gateway ]
}

module "monitoring" {
    source = "./modules/monitoring"
    depends_on = [ module.dashboard, module.gateway ]
    storage_class = kubernetes_storage_class.local-storage.metadata[0].name
}

#module "logging" {
#    source = "./modules/logging"
#    depends_on = [ module.dashboard, module.gateway ]
#    storage_class = kubernetes_storage_class.local-storage.metadata[0].name
#}

