provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"

  # backend "s3" {
  #   bucket         = "terraform-state"
  #   key            = "terraform.tfstate"
  #   region         = var.region
  #   dynamodb_table = "terraform-lock"
  # }
}
