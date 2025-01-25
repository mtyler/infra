terraform {
  required_version = ">= 0.13"
}

locals {
  context = var.context
  namespace = "gateway"
  hostname = var.hostname
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
          "name" = "http-cp1"
          "port" = 80
          "protocol" = "HTTP"
          "hostname" = "cp1"
          
        },
        {
          "name" = "http"
          "port" = 80
          "protocol" = "HTTP"
          "hostname" = "*.${local.hostname}"
        },
        {
          "name" = "https"
          "port" = 443
          "protocol" = "HTTPS"
          "hostname" = "*.${local.hostname}"
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

resource "kubernetes_manifest" "ReferenceGrant_dashboard" {
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1beta1"
    "kind" = "ReferenceGrant"
    "metadata" = {
      "name" = "dashboard-grant"
      "namespace" = "dashboard"
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
      hostnames = [
        "graf.${local.hostname}"
      ]
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

resource "kubernetes_manifest" "http_route_prometheus" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "HTTPRoute"
    metadata = {
      name = "http-route-prometheus"
      namespace = local.namespace
    }
    spec = {
      parentRefs = [
        {
          name = "gateway"
          sectionName = "http"
        }
      ]
      hostnames = [
        "prom.${local.hostname}"
      ]
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
              name = "prometheus-kube-prometheus-prometheus"
              port = 9090
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "http_route_alertmanager" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "HTTPRoute"
    metadata = {
      name = "http-route-alertmanager"
      namespace = local.namespace
    }
    spec = {
      parentRefs = [
        {
          name = "gateway"
          sectionName = "http"
        }
      ]
      hostnames = [
        "alert.${local.hostname}"
      ]
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
              name = "prometheus-kube-prometheus-alertmanager"
              port = 9093
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "https_route_dashboard" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind = "HTTPRoute"
    metadata = {
      name = "https-route-dashboard"
      namespace = local.namespace
    }
    spec = {
      parentRefs = [
        {
          name = "gateway"
          sectionName = "https"
        }
      ]
      hostnames = [
        "dash.${local.hostname}"
      ]
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
              namespace = "dashboard"
              name = "kubernetes-dashboard-kong-proxy"
              port = 443
            }
          ]
        }
      ]
    }
  }
}
