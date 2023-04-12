terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-fragmenty"
    key            = "terraform-state/terraform.tfstate"
    dynamodb_table = "terraform-state-lock-fragmenty"
    region         = "eu-central-1"
    profile        = "terraform"
  }
}
