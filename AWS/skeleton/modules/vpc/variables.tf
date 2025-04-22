variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "demo-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_public_subnets" {
  description = "List of public subnets with AZ and CIDR."
  type = list(object({
    az   = string
    cidr = string
    name = string
  }))
  default = [
    {
      az   = "us-east-1a"
      cidr = "10.1.0.0/24"
      name = "AZ-A public subnet"
    },
    {
      az   = "us-east-1b"
      cidr = "10.1.1.0/24"
      name = "AZ-B public subnet"
    }
  ]
}

variable "vpc_map_public_ip_on_launch" {
  description = "Map public IP on launch for public subnets."
  type        = bool
  default     = true
}

variable "vpc_private_subnets" {
  description = "List of service subnets with AZ and CIDR."
  type = list(object({
    az   = string
    cidr = string
    name = string
  }))
  default = [{
    az   = "us-east-1a"
    cidr = "10.1.2.0/24"
    name = "AZ-A Data private subnet"
    },
    {
      az   = "us-east-1b"
      cidr = "10.1.3.0/24"
      name = "AZ-B Data private subnet"
    }
  ]
}

