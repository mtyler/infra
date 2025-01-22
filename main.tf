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

resource "kubernetes_persistent_volume" "local-pv" {
  metadata {
    name = "local-pv"
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    persistent_volume_source {
        local {
            path = "/usr/data"
        }
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = "local-storage"
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key = "kubernetes.io/hostname"
            operator = "In"
            values = [
                "cp1",
                "n1",
                "n2",
                "test-control-plane"
                ]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "local-pvc" {
  metadata {
    name = "local-pvc"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "local-storage"
  }
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
    slack_api_url = var.slack_api_url
}

module "logging" {
    source = "./modules/logging"
    depends_on = [ module.dashboard, module.gateway ]
    storage_class = kubernetes_storage_class.local-storage.metadata[0].name
}

module "security" {
    source = "./modules/security"
    depends_on = [ module.dashboard, module.gateway ]
}
