terraform {
  required_version = ">= 0.13"
}

locals {
  context = var.context
  namespace = "gateway"
}

resource "kubernetes_manifest" "gateway" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind" = "Gateway"
    "metadata" = {
      "name" = "gateway"
      "namespace" = local.namespace
    }
    "spec" = {
      "gatewayClassName" = "nginx"
      "listeners" = [
        {
          "name" = "http"
          "port" = 80
          "protocol" = "HTTP"
#          "hostname" = "localhost"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "ReferenceGrant" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1beta1"
    "kind" = "ReferenceGrant"
    "metadata" = {
      "name" = "monitoring-grant"
      "namespace" = "monitoring"
    }
    "spec" = {
      "from" = [
        {
          "group" = "gateway.networking.k8s.io"
          "kind" = "HTTPRoute"
          "namespace" = "gateway"
        }
      ]
      "to" = [
        {
          "group" = ""
          "kind" = "Service"
        }
      ]
    }
  }
  
}

resource "kubernetes_manifest" "http_route_grafana" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "HTTPRoute"
    metadata = {
      name = "http-route-grafana"
      namespace = local.namespace
    }
    spec = {
      parentRefs = [
        {
          name = "gateway"
          sectionName = "http"
        }
      ]
#      hostnames = [
#        "localhost"
#      ]
      rules = [
        {
          matches = [
            {
              path = {
                type = "PathPrefix"
                value = "/"
              }
            }
          ]
          backendRefs = [
            {
              namespace = "monitoring"
              name = "prometheus-grafana"
              port = 80
            }
          ]
        }
      ]
    }
  }
}
