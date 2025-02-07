variable "namespace" {
  description = "The namespace to use for this module"
  default = "monitoring"
}

#variable "storage_class_name" {
#  description = "Storage class to be used for persistent volumes"
#}

variable "slack_api_url" {
  description = "Slack API URL to be used for alertmanager. Set using TF_VAR_slack_api_url in .env"
  sensitive = true
}

variable "slack_channel" {
  description = "Slack channel to be used for alertmanager"
  default = "#alertmanager"
}
