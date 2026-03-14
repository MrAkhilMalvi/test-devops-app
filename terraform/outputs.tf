output "ecr_repo" {
  description = "Amazon ECR repository URL."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "Amazon ECS cluster name."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Amazon ECS service name."
  value       = aws_ecs_service.app.name
}

output "deployed_image" {
  description = "Fully qualified Docker image deployed to ECS."
  value       = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
}

output "ec2_public_ip" {
  description = "Public IP address of the ECS EC2 host."
  value       = aws_instance.ecs.public_ip
}

output "app_url" {
  description = "Public URL for the application running on ECS EC2."
  value       = "http://${aws_instance.ecs.public_ip}:${var.container_port}"
}
