variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "create_key_pair" {
  description = "Create a new key pair for EC2 instances."
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Name of the key pair to use for EC2 instances."
  type        = string
  default     = "lab-key"
}

variable "public_key_path" {
  description = "Path to the public key file."
  type        = string
  default     = "out/lab-key.pub"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance."
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name of the EC2 instance."
  type        = string
  default     = "bastion"
}

variable "vpc_id" {
  description = "ID of the VPC to launch the EC2 instance in."
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "ID of the subnet to launch the EC2 instance in."
  type        = string
  default     = ""
}
