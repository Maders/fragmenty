data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "lb_access_logs" {
  bucket = "fragmenty-lb-access-log"
}

resource "aws_s3_bucket_acl" "lb_access_log_acl" {
  bucket = aws_s3_bucket.lb_access_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "lb_access_logs_policy" {
  bucket = aws_s3_bucket.lb_access_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.lb_access_logs.arn}/*"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
      },
      {
        Action   = "s3:GetBucketAcl"
        Effect   = "Allow"
        Resource = aws_s3_bucket.lb_access_logs.arn
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
      }
    ]
  })
}


resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow inbound traffic on port 80"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow inbound traffic on port 443"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "fragmenty" {
  name               = "fragmenty-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.allow_web.id,
    aws_security_group.allow_https.id,
    var.default_sg
  ]
  subnets            = var.subnets

  depends_on = [aws_s3_bucket.lb_access_logs]
  access_logs {
    bucket  = aws_s3_bucket.lb_access_logs.bucket
    prefix  = "load-balancer-logs"
    enabled = true
  }
}

resource "aws_lb_target_group" "fragmenty" {
  depends_on = [aws_lb.fragmenty]
  name       = "fragmenty-tg"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id

  health_check {
    path                = "/"
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

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = aws_lb_listener.fragmenty.arn
  priority     = 1

  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.fragmenty.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fragmenty.arn
  }
}

