terraform {
    required_version = ">= 0.13"

}

provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = var.context
}


resource "kubernetes_namespace" "cafe" {
  metadata {
    name = "cafe"
  }
  depends_on = [ module.dashboard, module.monitoring, module.gateway ]
}

resource kubernetes_deployment "coffee" {
  metadata {
    name = "coffee"
    namespace = kubernetes_namespace.cafe.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "coffee"
      }
    }
    template {
      metadata {
        labels = {
          app = "coffee"
        }
      }
      spec {
        container {
          image = "nginxdemos/nginx-hello:plain-text"
          name  = "coffee"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "coffee" {
  metadata {
    name = "coffee"
    namespace = kubernetes_namespace.cafe.metadata[0].name
  }
  spec {
    selector = {
      app = "coffee"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_deployment" "tea" {
  metadata {
    name = "tea"
    namespace = kubernetes_namespace.cafe.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "tea"
      }
    }
    template {
      metadata {
        labels = {
          app = "tea"
        }
      }
      spec {
        container {
          image = "nginxdemos/nginx-hello:plain-text"
          name  = "tea"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource kubernetes_service "tea" {
  metadata {
    name = "tea"
    namespace = kubernetes_namespace.cafe.metadata[0].name
  }
  spec {
    selector = {
      app = "tea"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_manifest" "gateway" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind" = "Gateway"
    "metadata" = {
      "name" = "gateway"
      "namespace" = kubernetes_namespace.cafe.metadata[0].name
    }
    "spec" = {
      "gatewayClassName" = "nginx"
      "listeners" = [
        {
          "name" = "http"
          "port" = 80
          "protocol" = "HTTP"
          "hostname" = "*.example.com"
        }
      ]
    }
  }
  depends_on = [ module.gateway ]
}

resource "kubernetes_manifest" "HTTPRoute_coffee" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind" = "HTTPRoute"
    "metadata" = {
      "name" = "coffee"
      "namespace" = kubernetes_namespace.cafe.metadata[0].name
    }
    "spec" = {
      "parentRefs" = [
        {
          "name" = "gateway"
          "sectionName" = "http"
        }
      ]
      "hostnames" = [
        "cafe.example.com"
      ]
      "rules" = [
        {
          "matches" = [
            {
              "path" = {
                "type" = "PathPrefix"
                "value" = "/coffee"
              }
            }
          ]
          "backendRefs" = [
            {
              "name" = "coffee"
              "port" = 80
            }
          ]
        }
      ]
    }
  }  
  depends_on = [ module.gateway ]
}

resource "kubernetes_manifest" "HTTPRoute_tea" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind" = "HTTPRoute"
    "metadata" = {
      "name" = "tea"
      "namespace" = kubernetes_namespace.cafe.metadata[0].name
    }
    "spec" = {
      "parentRefs" = [
        {
          "name" = "gateway"
          "sectionName" = "http"
        }
      ]
      "hostnames" = [
        "cafe.example.com"
      ]
      "rules" = [
        {
          "matches" = [
            {
              "path" = {
                "type" = "PathPrefix"
                "value" = "/tea"
              }
            }
          ]
          "backendRefs" = [
            {
              "name" = "tea"
              "port" = 80
            }
          ]
        }
      ]
    }
  }  
  depends_on = [ module.gateway ]
}

output "cafe-namespace" {
  description = "The namespace used to create cafe."
  value       = kubernetes_namespace.cafe.metadata[0].name
}
