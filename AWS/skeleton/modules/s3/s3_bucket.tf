# module "kms_key_s3" {
#   source = "terraform-aws-modules/kms/aws"
#   version = "3.1.1"

#   description = var.kms_description
#   enable_key_rotation = var.kms_enable_key_rotation
#   deletion_window_in_days = var.kms_deletion_window_in_days

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.kms_name}"
#     }
#   )
# }

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.0.0"

  bucket = var.bucket_name
  acl    = var.bucket_acl

  force_destroy = true

  tags = merge(
    var.tags,
    {
      Name = "${var.bucket_name}"
    }
  )

  lifecycle_rule = [
    {
      id      = "lifecycle_rule"
      enabled = true
      abort_incomplete_multipart_upload_days = 7
      expiration {
        days = 30
      }
    }
  ]
}