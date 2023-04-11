locals {
  ecr_repository_url = aws_ecr_repository.scrapy_lambda_repository.repository_url
  api_hash           = data.external.git_hash_api.result["sha_commit"]
  spider_hash        = data.external.git_hash_spider.result["sha_commit"]
}

resource "null_resource" "push_spider_image" {
  depends_on = [null_resource.push_play_image]
  triggers = {
    always_run = local.spider_hash
  }

  # if you want to build images in terraform apply you should clone this repo with --recursive flag to have fragmenty-spider and fragmenty-api suubmodule contents
  # if you don't so comment the docker build lines (for example in that case that CI/CD made the images and pushed to the ECR repo)
  provisioner "local-exec" {
    command = <<EOT
      aws ecr --profile ${var.aws_profile} get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.ecr_repository_url}
      docker build -t ${var.lambda_container_image_name} -f "${path.module}/../../../fragmenty-spider/Dockerfile" "${path.module}/../../../fragmenty-spider/"
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
      docker build -t ${var.play_container_image_name} -f "${path.module}/../../../fragmenty-api/Dockerfile" "${path.module}/../../../fragmenty-api/"
      docker tag ${var.play_container_image_name}:latest ${local.ecr_repository_url}:${var.play_container_image_name}
      docker push ${local.ecr_repository_url}:${var.play_container_image_name}
EOT
  }
}
