locals {
  ecr_repository_url = aws_ecr_repository.scrapy_lambda_repository.repository_url
  api_hash           = data.external.git_hash_api.result["sha_commit"]
  spider_hash        = data.external.git_hash_spider.result["sha_commit"]
}

resource "null_resource" "push_spider_image" {
  triggers = {
    always_run = local.spider_hash
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ecr --profile ${var.aws_profile} get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.ecr_repository_url}
      docker build test-spider "${path.module}/../../../fragmenty-spider/Dockerfile"
      docker tag ${var.lambda_container_image_name}:latest ${local.ecr_repository_url}:${var.lambda_container_image_name}
      docker push ${local.ecr_repository_url}:${var.lambda_container_image_name}
EOT
  }
}

resource "null_resource" "push_play_image" {
  triggers = {
    always_run = local.api_hash
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ecr --profile ${var.aws_profile} get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.ecr_repository_url}
      docker build test-api "${path.module}/../../../fragmenty-api/Dockerfile"
      docker tag ${var.play_container_image_name}:latest ${local.ecr_repository_url}:${var.play_container_image_name}
      docker push ${local.ecr_repository_url}:${var.play_container_image_name}
EOT
  }
}
