resource "aws_ecs_task_definition" "app" {
  family                   = "app-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "app"

      image = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"

      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]

      environment = [
        {
          name  = "VERSION"
          value = var.image_tag
        },
        {
          name  = "PORT"
          value = "3000"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "EC2"

  depends_on = [
    aws_ecs_task_definition.app
  ]
}