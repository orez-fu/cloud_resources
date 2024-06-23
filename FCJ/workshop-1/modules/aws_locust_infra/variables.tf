
### VPC ###
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project Name"
  type        = string
}

variable "tags" {
  description = "A map of additional tags to add all resource"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "Application CIDR for all AWS resource"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets CIDR"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnets CIDR, required at least 2 subnets"
  type        = list(string)
}

variable "azs" {
  description = "AZs in AWS Region"
  type        = list(string)
}

variable "igw_enable" {
  description = "The flag to enable or disable the Internet Gateway"
  type        = bool
  default     = true
}

variable "nat_gateway_enable" {
  description = "The flag to enable or disable the NAT Gateway"
  type        = bool
  default     = true
}

### End VPC ### 

### EC2 ###
variable "bastion_instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "bastion_sg_cidr_blocks" {
  description = "Bastion Security Group CIDR"
  type        = list(string)
}

variable "bastion_key_name" {
  description = "Bastion Key Pair Name"
  type        = string
}

