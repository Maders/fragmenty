locals {
  ecr_repository_url = aws_ecr_repository.scrapy_lambda_repository.repository_url
}

resource "null_resource" "push_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ecr --profile ${var.aws_profile} get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.ecr_repository_url}
      docker tag ${var.container_image_name}:latest ${local.ecr_repository_url}:latest
      docker push ${local.ecr_repository_url}:latest
EOT
  }
}
