variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "8_prod"
}

variable "app_name" {
  default = "test-app"
}
variable "region" {
  default = "ap-south-1"
}
