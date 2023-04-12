variable "aws_profile" {
  description = "AWS profile to use for authentication"
  default     = "terraform"
}

variable "aws_region" {
  description = "AWS region to deploy the resources"
  default     = "eu-central-1"
}

variable "s3_bucket_name" {
  description = "The s3 bucket name that you want to create"
  default     = "terraform-state-bucket-fragmenty"
}

variable "dynamodb_table_name" {
  description = "The s3 bucket name that you want to create"
  default     = "terraform-state-lock-fragmenty"
}
