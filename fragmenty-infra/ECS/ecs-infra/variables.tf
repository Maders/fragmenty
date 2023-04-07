variable "aws_profile" {
  description = "AWS profile to use for authentication"
  default     = "terraform"
}

variable "subnets" {
  description = "A list of subnet IDs where the resources will be deployed"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region to deploy the resources"
  default     = "eu-central-1"
}

variable "vpc_id" {
  description = "The VPC ID where resources will be deployed"
}

variable "hosted_zone_id" {
  description = "The ID of the Route53 hosted zone where the custom domain resides"
}

variable "custom_domain" {
  description = "The custom domain name for the application"
}

variable "s3_bucket_name" {
  description = "The s3 bucket name used for remote state"
  sensitive   = true
}

variable "dynamodb_table_name" {
  description = "The DynamoDB table name used for locking remote state"
  sensitive   = true
}

variable "mongo_uri" {
  description = "The MongoDB atlas connection string"
  sensitive   = true
}

variable "container_image_name" {
  description = "The name of the application docker image that you build locally"
  default     = "spider"
}
