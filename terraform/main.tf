resource "aws_ecs_cluster" "main" {
  name = "app-cluster"
}

# IAM role for ECS instance
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}


# EC2 for ECS
resource "aws_instance" "ecs" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ecs_profile.name

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=app-cluster >> /etc/ecs/ecs.config
EOF

  tags = {
    Name = "ecs-instance"
  }
}