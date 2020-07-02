terraform {
  required_version = "~> 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 1.2"
    }
  }
}
