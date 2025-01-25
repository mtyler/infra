variable "context" {
  description = "Context to be used for kubectl"
  type        = string
  default     = "kind-kind-test"
}

variable "hostname" {
  description = "Hostname to be used for the gateway"
  type        = string
  default     = "example.com"
}

