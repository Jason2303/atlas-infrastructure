terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Owner     = "Jason-Sefia"
      ManagedBy = "terraform"
      Project   = "atlas"
    }
  }
}

data "aws_caller_identity" "current" {}

