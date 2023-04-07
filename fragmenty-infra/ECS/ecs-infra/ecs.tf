resource "aws_ecs_cluster" "fragmenty" {
  name = "general-ecs-cluster"
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
  name            = "fragmenty-scala-play-service"
  cluster         = aws_ecs_cluster.fragmenty.id
  task_definition = aws_ecs_task_definition.fragmenty.arn
  desired_count   = 2
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.fragmenty.arn
    container_name   = "fragmenty-scala-play-app"
    container_port   = 9000
  }
}

resource "aws_cloudwatch_log_group" "fragmenty" {
  name              = "/ecs/fragmenty-scala-play-app"
  retention_in_days = 14
}
