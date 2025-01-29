terraform {
  required_version = ">= 0.13"
  required_providers {
      kubectl = {
        source = "gavinbunney/kubectl"
      }
  }  
}

locals {
#  context = var.context
  namespace = "gateway"
}


# Install Gateway API 
# details: https://gateway-api.sigs.k8s.io/guides/#install-standard-channel
data "http" "gateway_api_crds" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml"

  request_headers = {
    Accept = "application/yaml"
  }
}

data "kubectl_file_documents" "gateway_api_crds" {
    content = data.http.gateway_api_crds.response_body
}

# Using data.http.gateway_api_install.response_body directly in kubectl_manifest
# results in only the first manifest being applied.
resource "kubectl_manifest" "gateway_api_crds" {
    for_each  = data.kubectl_file_documents.gateway_api_crds.manifests
    yaml_body = each.value
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace
  }
}

# Install nginx gateway fabric
resource "helm_release" "nginx_gateway" {
  create_namespace = true
  name       = "ngf"
  namespace  = local.namespace
  repository = "oci://ghcr.io/nginxinc/charts/"
  chart      = "nginx-gateway-fabric"
  timeout    = 900
  set {
    name = "nginxGateway.config.logging.level"
    value = "debug"
  }
  set {
    name = "service.create"
    value = "false"
  }
  ### the following is requiered to complete the config
  # 1. port forward
  # kubectl port-forward svc/ngf-nginx-gateway-fabric 8080:80 -n nginx-gateway
  # 2. dns resolution
  #     curl --resolve cafe.example.com:8080:127.0.0.1 http://cafe.example.com:8080/tea
  #   or
  #     /etc/hosts can be updated with 127.0.0.1 localhost cafe.example.com
  #     curl http://cafe.example.com:8080/tea
}

resource "kubernetes_service" "gateway" {
  metadata {
    name     = "${helm_release.nginx_gateway.name}-${helm_release.nginx_gateway.chart}"
#    name      = "ngf-nginx-gateway-fabric"
    namespace = local.namespace
  }
  spec {
    type = "NodePort"
    selector = {
      "app.kubernetes.io/instance" = helm_release.nginx_gateway.name
      "app.kubernetes.io/name"     = helm_release.nginx_gateway.chart
    }
    port {
        name       = "http"
        port       = 80
        target_port = 80
        node_port = 30080
    } 
    port {
        name       = "https"
        port       = 443
        target_port = 443
        node_port = 30443
    }
  }
}
