#################################################################################################################
# Define the settings for the rook-ceph cluster with common settings for a small test cluster.
# All nodes with available raw devices will be used for the Ceph cluster. One node is sufficient
# in this example.
#################################################################################################################
resource "kubernetes_manifest" "cluster_test" {
  count = var.rook_ceph_cluster_nohelm ? 1 : 0
  field_manager {
    force_conflicts = true
  }
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephCluster"
    metadata = {
      name      = "rook-ceph"
      namespace = "rook-ceph"
    }
    spec = {
      dataDirHostPath = "/var/lib/rook"
      cephVersion = {
        image             = "quay.io/ceph/ceph:v19"
        allowUnsupported  = true
      }
      mon = {
        count                 = 1
        allowMultiplePerNode  = true
      }
      mgr = {
        count                 = 1
        allowMultiplePerNode  = true
        modules = [{
          name    = "rook"
          enabled = true
        }]
      }
      dashboard = {
        enabled = true
      }
      crashCollector = {
        disable = true
      }
      storage = {
        useAllNodes              = true
        useAllDevices            = true
        allowDeviceClassUpdate   = true
        allowOsdCrushWeightUpdate = false
      }
      monitoring = {
        enabled = false
      }
      healthCheck = {
        daemonHealth = {
          mon = {
            interval = "45s"
            timeout  = "600s"
          }
        }
      }
      priorityClassNames = {
        all = "system-node-critical"
        mgr = "system-cluster-critical"
      }
      disruptionManagement = {
        managePodBudgets = true
      }
      cephConfig = {
        global = {
          osd_pool_default_size        = "1"
          mon_warn_on_pool_no_redundancy = "false"
          bdev_flock_retry             = "20"
          bluefs_buffered_io           = "false"
          mon_data_avail_warn          = "10"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "blockpool_test" {
  count = var.rook_ceph_cluster_nohelm ? 1 : 0
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephBlockPool"
    metadata = {
      name      = "builtin-mgr"
      namespace = "rook-ceph"
    }
    spec = {
      name       = ".mgr"
      replicated = {
        size                   = 1
        requireSafeReplicaSize = false
      }
    }
  }
}

resource "kubernetes_manifest" "storageclass_rook_ceph_block" {
  count = var.rook_ceph_cluster_nohelm ? 1 : 0
  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "rook-ceph-block"
    }
    provisioner = "rook-ceph.rbd.csi.ceph.com"
    parameters = {
      clusterID                             = "rook-ceph"
      pool                                  = "replicapool"
      imageFormat                           = "2"
      imageFeatures                         = "layering"
      "csi.storage.k8s.io/provisioner-secret-name"        = "rook-csi-rbd-provisioner"
      "csi.storage.k8s.io/provisioner-secret-namespace"   = "rook-ceph"
      "csi.storage.k8s.io/controller-expand-secret-name"  = "rook-csi-rbd-provisioner"
      "csi.storage.k8s.io/controller-expand-secret-namespace" = "rook-ceph"
      "csi.storage.k8s.io/node-stage-secret-name"         = "rook-csi-rbd-node"
      "csi.storage.k8s.io/node-stage-secret-namespace"    = "rook-ceph"
      "csi.storage.k8s.io/fstype"                         = "ext4"
    }
    reclaimPolicy        = "Delete"
    allowVolumeExpansion = true
  }
}

resource "kubernetes_manifest" "replicapool" {
  count = var.rook_ceph_cluster_nohelm ? 1 : 0
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephBlockPool"
    metadata = {
      name      = "replicapool"
      namespace = "rook-ceph"
    }
    spec = {
      failureDomain = "osd"
      replicated = {
        size                   = 1
        requireSafeReplicaSize = false
      }
    }
  }
}

