
#output "gateway_namespace" {
#  description = "The namespace used to create prometheus."
#  value       = data.kubectl_path_documents.manifests-prometheus.vars.namespace
#}

#output "gateway_svc_port" {
#  description = "The nodeport used to access the gateway service."
#  value = data.kubernetes_service.nginx_gateway.spec.ports[0].node_port
#}
