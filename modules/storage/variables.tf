variable "storage_type" {
  description = "The type of storage to setup for the cluster"
}
variable "nfs_share" {
  description = "The directory of the nfs share drive"
}

variable "nfs_server" {
  description = "The fqdn|ip of the nfs server"
}

variable "storage_class_name" {
  description = "The name used to create the storage class"
  default = "nfs-csi"
}

variable "namespace" {
  description = "The namespace to use for this module"
  default = "storage"
}

