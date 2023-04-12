resource "aws_ecs_cluster" "fragmenty" {
  name = "general-ecs-cluster"
}

resource "aws_security_group" "ecs_instance" {
  name        = "ecs-instance-sg"
  description = "Security group for ECS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51678
    to_port     = 51678
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_instance" "ecs_instance" {
  depends_on    = [aws_ecs_cluster.fragmenty]
  ami           = "ami-0161e00a80b3f7535"
  instance_type = "t2.micro"

  key_name             = "aws"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  # security_groups      = [aws_security_group.ecs_instance.id]
  vpc_security_group_ids = [aws_security_group.ecs_instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.fragmenty.name} >> /etc/ecs/ecs.config
              EOF
}


resource "random_string" "play-app_secret" {
  length  = 25
  special = true
}

resource "aws_ecs_task_definition" "fragmenty" {
  depends_on = [null_resource.push_play_image]

  family = "fragmenty-task"
  container_definitions = jsonencode([
    {
      "name" : "fragmenty-scala-play-service",
      "image" : "${aws_ecr_repository.scrapy_lambda_repository.repository_url}:${var.play_container_image_name}",
      "portMappings" : [
        {
          "containerPort" : 9000,
          "hostPort" : 80,
          "protocol" : "tcp"
        }
      ],
      "memory" : 800,
      "essential" : true,
      "environment" : [
        {
          "name" : "APPLICATION_SECRET",
          # the secret should not repreduce every time randomly but I use the random string for now
          "value" : "${random_string.play-app_secret.result}"
        },
        {
          "name" : "MONGODB_URI",
          "value" : "${var.mongo_uri}"
        },
        {
          "name" : "ALLOWED_HOSTS",
          "value" : "${var.api_allowed_hosts}"
        }

      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/fragmenty-scala-play-app",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
    ]
  )
}

resource "aws_ecs_service" "fragmenty" {
  depends_on      = [aws_ecs_task_definition.fragmenty, aws_lb_target_group.fragmenty]
  name            = "fragmenty-scala-play-service"
  cluster         = aws_ecs_cluster.fragmenty.id
  task_definition = aws_ecs_task_definition.fragmenty.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.fragmenty.arn
    container_name   = "fragmenty-scala-play-service"
    container_port   = 9000
  }
}

resource "aws_cloudwatch_log_group" "fragmenty" {
  name              = "/ecs/fragmenty-scala-play-app"
  retention_in_days = 14

}
