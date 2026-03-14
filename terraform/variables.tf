variable "app_name" {
  description = "Application and repository name."
  type        = string
  default     = "test-app"
}

variable "region" {
  description = "AWS region used for ECR and ECS resources."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment name used in tags."
  type        = string
  default     = "prod"
}

variable "image_tag" {
  description = "Docker image tag deployed to ECS."
  type        = string
  default     = "1_prod"
}

variable "instance_type" {
  description = "EC2 instance type used by the ECS cluster."
  type        = string
  default     = "t3.micro"
}

variable "container_port" {
  description = "Application port exposed by the container and EC2 host."
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks to keep running."
  type        = number
  default     = 1
}
