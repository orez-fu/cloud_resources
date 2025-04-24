variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

# variable "kms_description" {
#   description = "Description of the KMS key."
#   type        = string
#   default     = "KMS key for S3 bucket"
# }

# variable "kms_enable_key_rotation" {
#   description = "Enable key rotation for the KMS key."
#   type        = bool
#   default     = true
# }

# variable "kms_deletion_window_in_days" {
#   description = "Deletion window in days for the KMS key."
#   type        = number
#   default     = 30
# }

variable "kms_name" {
  description = "Name of the KMS key."
  type        = string
  default     = "s3-kms-key"
}

variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
  default     = "my-s3-bucket"
}

variable "bucket_acl" {
  description = "Access control list for the S3 bucket."
  type        = string
  default     = "private"
}
