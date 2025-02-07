# Install the Rook Ceph Operator
resource "helm_release" "rook-ceph-operator" {
  create_namespace = true
  namespace = "rook-ceph"
  name = "rook-ceph"
  repository = "https://charts.rook.io/release"
  chart = "rook-ceph"
  set {
    name = "enableDiscoveryDaemon"
    value = "true"
  }
}

# Install the Rook Ceph Cluster
resource "helm_release" "rook-ceph-cluster" {
  count = var.rook_ceph_cluster ? 1 : 0
  create_namespace = true
  namespace = "rook-ceph-cluster"
  name = "rook-ceph-cluster"
  repository = "https://charts.rook.io/release"
  chart = "rook-ceph-cluster"
  set {
    name = "operatorNamespace"
    value = helm_release.rook-ceph-operator.namespace
  }
  #set {
  #  # mon.count should be set to a min of 3 for production
  #  name = "cephClusterSpec.mon.count"
  #  value = "3"
  #}
  #set {
  #  # mgr.count should be set to 2 for production
  #  name = "cephClusterSpec.mgr.count"
  #  value = "2"
  #}
  #set {
  #  # turn off Block Pools 
  #  name = "cephBlockPools[0]"
  #  value = "[]"
  #}
  #set {
  #  # turn off CephFS
  #  name = "cephFilesystems[0]"
  #  value = "[]"
  #}
  depends_on = [ helm_release.rook-ceph-operator ]
}

