module "s3_images" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/s3?ref=terraform-aws-s3_v0.2.1"
  
  s3_bucket = {
    name = "${var.project}-${var.env}-images"
    versioning = "Enabled"
    sse = {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_images.arn
    }
    lifecycle_versioning = {
      status = "Enabled"
    }
    lifecycle = [
      {
        id = "manage_image_lifecycle"
        status = "Enabled"
        expiration_days = 90
        transition_days = 30
        transition_days_standard_ia = 30
        transition_days_glacier = 90
      }
    ]
  }
}

module "s3_alb_logs" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/s3?ref=terraform-aws-s3_v0.2.1"
  
  s3_bucket = {
    name = "${var.project}-${var.env}-alb-logs"
    versioning = "Enabled"
    sse = {
      sse_algorithm = "AES256"
    }
    lifecycle_versioning = {
      status = "Enabled"
    }
    lifecycle = [
      {
        id = "manage_alb_logs_lifecycle"
        status = "Enabled"
        expiration_days = 30
        transition_days = 30
        transition_days_standard_ia = 30
        transition_days_glacier = 90
      }
    ]
  }
}

module "s3_app_logs" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/s3?ref=terraform-aws-s3_v0.2.1"

  s3_bucket = {
    name = "${var.project}-${var.env}-app-logs"
    versioning = "Enabled"
    sse = {
      sse_algorithm = "AES256"
    }
    lifecycle_versioning = {
      status = "Enabled"
    }
    lifecycle = [
      {
        id = "manage_app_logs_lifecycle"
        status = "Enabled"
        expiration_days = 30
        transition_days = 30
        transition_days_standard_ia = 30
        transition_days_glacier = 90
      }
    ]
  }
}

module "s3_lambda_deployments" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/s3?ref=terraform-aws-s3_v0.2.1"

  s3_bucket = {
    name = "${var.project}-${var.env}-lambda-deployments"
    versioning = "Enabled"
    sse = {
      sse_algorithm = "AES256"
    }
    lifecycle_versioning = {
      status = "Enabled"
    }
    lifecycle = [
      {
        id = "manage_lambda_deployments_lifecycle"
        status = "Enabled"
        expiration_days = 90
        transition_days = 30
        transition_days_standard_ia = 30
        transition_days_glacier = 90
      }
    ]
  }
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "s3_alb_logs_policy" {
  statement {
    sid    = "AllowALBLogsDelivery"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    
    actions = [
      "s3:PutObject"
    ]
    
    resources = [
      "arn:aws:s3:::${var.project}-${var.env}-alb-logs/*"
    ]
  }
  
  statement {
    sid    = "AllowALBLogsCheck"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    
    actions = [
      "s3:GetBucketAcl"
    ]
    
    resources = [
      "arn:aws:s3:::${var.project}-${var.env}-alb-logs"
    ]
  }
}
