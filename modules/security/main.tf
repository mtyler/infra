
locals {
  namespace = "security"
}

resource "helm_release" "falco" {
  create_namespace = true
  name       = "falcosecurity"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  namespace  = local.namespace
  set {
    name = "driver.kind"
    value = "modern_ebpf"
  }
  
}