
#output "dashboard-namespace" {
#  description = "The namespace used to create dashboard."
#  value       = helm_release.kubernetes-dashboard.namespace
#}
#
#output "prometheus-namespace" {
#  description = "The namespace used to create prometheus."
#  value       = data.kubectl_path_documents.manifests-prometheus.vars.namespace
#}