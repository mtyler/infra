resource "helm_release" "cert_manager" {
  create_namespace = true
  namespace = "cert-manager"
  chart = "cert-manager"
  repository = "https://charts.jetstack.io"
  name = "cert-manager"
  set {
    name = "crds.enabled"
    value = "true"
  }
}
