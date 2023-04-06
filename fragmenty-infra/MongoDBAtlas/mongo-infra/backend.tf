terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.8.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-mongodb"
    key            = "terraform-state/terraform.tfstate"
    dynamodb_table = "terraform-state-lock-mongodb"
    region         = "eu-central-1"
    profile        = "terraform"
  }
}
