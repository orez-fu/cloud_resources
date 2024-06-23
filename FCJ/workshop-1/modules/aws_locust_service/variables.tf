
### Common ### 
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

### ECS Service ### 
variable "ecs_task_locust_version" {
  description = "Locust Docker Image"
  type        = string
  default     = "2.29.0"
}

variable "ecs_task_locust_file" {
  description = "Locust file from efs volume to run the test, the path already have '/mnt/efs/'. Example: hello_world/locustfile.py"
  type        = string
}
