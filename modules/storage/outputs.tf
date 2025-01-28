output "storage_class" {
  description = "The storage class created by this module"
  value = resource.kubernetes_storage_class.csi-nfs.metadata.0.name
}
