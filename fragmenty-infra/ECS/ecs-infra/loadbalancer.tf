resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow inbound traffic on port 80"
  vpc_id      = var.vpc_id

  lifecycle {
    prevent_destroy = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "fragmenty" {
  name               = "fragmenty-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = var.subnets
}

resource "aws_lb_target_group" "fragmenty" {
  name     = "fragmenty-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    prevent_destroy = true
  }


  health_check {
    path                = "/healthcheck"
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "fragmenty" {
  load_balancer_arn = aws_lb.fragmenty.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fragmenty.arn
  }
}

# resource "aws_lb_listener_rule" "api_rule" {
#   listener_arn = aws_lb_listener.fragmenty.arn

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.fragmenty.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api*"]
#     }
#   }
# }



