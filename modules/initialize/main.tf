terraform {
  required_version = ">= 0.13"
  required_providers {
      kubectl = {
        source = "gavinbunney/kubectl"
      }
  }  
}
## Install Gateway API crds
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

# Install the Rook Ceph Operator
resource "helm_release" "rook-ceph-operator" {
  create_namespace = true
  namespace = "rook-ceph"
  name = "rook-ceph"
  repository = "https://charts.rook.io/release"
  chart = "rook-ceph"
  ## csi switches
  set {
    name = "csi.enableRbdDriver"
    value = "true"
  }
  set {
    name = "csi.enableCephfsDriver"
    value = "false"
  }
  set {
    name = "csi.disableCsiDriver"
    value = "false"
  }
  set {
    name = "csi.enableCSIHostNetwork"
    value = "true"
  }
  set {
    name = "csi.enableCephfsSnapshotter"
    value = "false"
  }
  set {
    name = "csi.enableNFSSnapshotter"
    value = "false"
  }
  set {
    name = "csi.enableRBDSnapshotter"
    value = "false"
  }
  set {
    name = "csi.provisionerReplicas"
    value = "1"
  }
  set {
    name = "enableDiscoveryDaemon"
    value = "true"
  }
  set {
    name = "discover.nodeAffinity"
    value = "node-cluster-role/storage="
  }
}