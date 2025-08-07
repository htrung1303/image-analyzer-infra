###################
# General Initialization
###################
terraform {
  required_version = ">= 1.3.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    template = "~> 2.0"
  }
  backend "s3" {
    profile = "image-analyzer-infra-dev"
    bucket  = "image-analyzer-infra-dev-iac-state"
    key     = "general/terraform.dev.tfstate"
    region  = "ap-northeast-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:ap-northeast-1:354852166473:key/27a3edec-d150-4011-9079-ddcf25cd5b6d"
    dynamodb_table = "image-analyzer-infra-dev-terraform-state-lock"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = "${var.project}-${var.env}"
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.env
    }
  }
}
data "aws_caller_identity" "current" {}
