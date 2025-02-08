variable "rook_ceph_cluster" {
  description = "Deploy the Rook Ceph Cluster with Helm"
  default = "false"
}

variable "rook_ceph_cluster_nohelm" {
  description = "Deploy the Rook Ceph Cluster without Helm"
  default = "false" 
}

