# Begin Dashboard setup
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "dashboard"
  }
}

resource "kubernetes_service_account" "admin_user" {
  metadata {
    name      = "admin-user"
    namespace = resource.kubernetes_namespace.namespace.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "admin_user" {
  metadata {
    name = resource.kubernetes_service_account.admin_user.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = resource.kubernetes_service_account.admin_user.metadata[0].name
    namespace = resource.kubernetes_namespace.namespace.metadata[0].name
  }
}

resource "kubernetes_secret" "admin_user" {
  metadata {
    name      = resource.kubernetes_service_account.admin_user.metadata[0].name
    namespace = resource.kubernetes_namespace.namespace.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = resource.kubernetes_service_account.admin_user.metadata[0].name
    }

  }
  type = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "helm_release" "kubernetes_dashboard" {
  create_namespace = false
  name       = "kubernetes-dashboard"
  namespace  = resource.kubernetes_namespace.namespace.metadata[0].name
  
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"

  # make dashboard available on http://localhost:8443
  # setup port-forwarding 
  # kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
  # 
  # get token
  # kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
}