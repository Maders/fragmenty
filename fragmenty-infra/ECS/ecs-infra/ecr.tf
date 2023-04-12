
resource "aws_ecr_repository" "scrapy_lambda_repository" {
  name = "fragmenty-registry"

  lifecycle {
    prevent_destroy = true
  }
}
