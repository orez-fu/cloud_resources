
variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "us-east-1"
}

variable "rke2_token" {
  description = "The RKE2 token for joining nodes to the cluster."
  type        = string
  default     = "my_rke2_token_must_be_secure"
}
