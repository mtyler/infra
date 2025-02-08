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

variable "rook_ceph" {
  description = "Deploy the Rook Ceph Operator"
  type        = bool
  default     = true
}

variable "rook_ceph_cluster" {
  description = "Deploy the Rook Ceph Cluster"
  type        = bool
  default     = false
}

variable "rook_ceph_cluster_nohelm" {
  description = "Deploy the Rook Ceph Cluster without Helm"
  type        = bool
  default     = true
}

variable "cert_manager_enabled" {
  description = "Deploy the Cert Manager"
  type        = bool
  default     = true
}

variable "metrics_server" {
  description = "Deploy the Metrics Server"
  type        = bool
  default     = true
}

variable "dashboard" {
  description = "Enable or disable the dashboard module"
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Enable or disable monitoring module"
  type        = bool
  default     = true
}