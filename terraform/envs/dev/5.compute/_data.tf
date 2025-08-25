data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "terraform_remote_state" "general" {
  backend = "s3"
  config = {
    bucket = "image-analyzer-infra-dev-iac-state"
    key    = "general/terraform.dev.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "admin" {
  backend = "s3"
  config = {
    bucket = "image-analyzer-infra-dev-iac-state"
    key    = "admin/terraform.dev.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "monitoring" {
  backend = "s3"
  config = {
    bucket = "image-analyzer-infra-dev-iac-state"
    key    = "monitoring/terraform.dev.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "messaging" {
  backend = "s3"
  config = {
    bucket = "image-analyzer-infra-dev-iac-state"
    key    = "messaging/terraform.dev.tfstate"
    region = "ap-northeast-1"
  }
}
