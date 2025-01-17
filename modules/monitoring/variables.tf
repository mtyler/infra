variable "storage_class" {
  description = "Storage class to be used for persistent volumes"
}

variable "slack_api_url" {
  description = "Slack API URL to be used for alertmanager. Set using TF_VAR_slack_api_url in .env"
  sensitive = true
}

