variable "context" {
  description = "Context to be used for kubectl"
  type        = string
  #default     = "kind-kind-test"
  #default     = "kubernetes-admin@kubernetes"
}

variable "slack_api_url" {
  description = "Slack API URL to be used for alertmanager. Set using TF_VAR_slack_api_url in .env"
  sensitive = true
}

variable "domain" {
  description = "Hostname to be used for the gateway"
  type        = string
  default     = "k8s.local"
}