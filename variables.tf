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
