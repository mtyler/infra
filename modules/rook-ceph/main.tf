

###
# 
# The following block is untested. Values were taken from rook_ceph examples/cluster-test.yaml
#
### Install the Rook Ceph Cluster
##resource "helm_release" "rook-ceph-cluster" {
##  count = var.rook_ceph_cluster ? 1 : 0
##  create_namespace = true
##  namespace = "rook-ceph-cluster"
##  name = "rook-ceph-cluster"
##  repository = "https://charts.rook.io/release"
##  chart = "rook-ceph-cluster"
##  set {
##    name = "operatorNamespace"
##    value = helm_release.rook-ceph-operator.namespace
##  }
##  set {
##    # mon.count should be set to a min of 3 for production
##    name = "cephClusterSpec.mon.count"
##    value = "1"
##  }
##  set {
##    # mgr.count should be set to 2 for production
##    name = "cephClusterSpec.mgr.count"
##    value = "1"
##  }
##  set {
##    name = "cephClusterSpec.mgr.modules[0].name"
##    value = "rook"
##  }
##  set {
##    name = "cephClusterSpec.mgr.modules[0].enabled"
##    value = "true"
##  }
##  set {
##    name = "cephClusterSpec.dashboard.enabled"
##    value = "true"
##  }
##  set {
##    name = "cephClusterSpec.crashCollector.enabled"
##    value = "false"
##  }
##  # Config cephBlockPools
##  set {
##    name = "cephBlockPools[0].spec.replicated.size"
##    value = "1"
##  }
##  set {
##    name = "cephBlockPools[0].spec.replicated.requireSafeReplicaSize"
##    value = "false"
##  }
##  # Config cephFilesystems
##  set {
##    name = "cephFilesystems[0].spec.metadataPool.replicated.size"
##    value = "1"
##  }
##  
##  depends_on = [ helm_release.rook-ceph-operator ]
##}

