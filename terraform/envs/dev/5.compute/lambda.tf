module "sns_event" {
  source = "git@github.com:framgia/sun-infra-iac.git//modules/sns?ref=terraform-aws-sns_v0.0.1"
  #basic
  env     = var.env
  project = var.project
  region  = var.region

  #sns
  sns_topic_name = "event"
  service        = "cloudwatch"
}

module "iam_role_lambda_event" {
  source = "git@github.com:framgia/sun-infra-iac.git//modules/iam-role?ref=terraform-aws-iam_v0.1.2"
  #basic
  env     = var.env
  project = var.project
  service = "lambda"

  #iam-role
  name               = "lambda-event"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  iam_custom_policy = {
    template = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource" : "*"
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "ssm:GetParameter",
              "ssm:GetParameters"
            ],
            "Resource" : "*"
          }
        ]
      }
    )
  }
}

module "lambda_event" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/lambda?ref=terraform-aws-lambda_v0.0.5"
  #basic
  project = var.project
  env     = var.env
  region  = var.region
  service = "sns"

  #lambda-zip
  lambda_zip_python = {
    code_path     = "./lambda-function/event"
    code_zip_path = "./lambda-function/event"
    code_zip_name = "event"
  }
  #lambda
  lambda_function = {
    name    = "event"
    role    = module.iam_role_lambda_event.iam_role_arn
    runtime = "python3.8"
    vpc_config = {
      subnet_ids         = data.terraform_remote_state.general.outputs.vpc_private_subnet_ids
      security_group_ids = [data.terraform_remote_state.general.outputs.lambda_ai_processor_security_group_id]
    }
    
    environment = {
      variables = {
        S3_IMAGES_BUCKET = data.terraform_remote_state.general.outputs.s3_images_bucket_name
        SQS_QUEUE_URL    = data.terraform_remote_state.messaging.outputs.sqs_worker_queue_url
      }
    }
  }
  #sns
  lambda_function_sns = [
    {
      topic_name = module.sns_event.sns_topic_name
      topic_arn  = module.sns_event.sns_topic_arn
    }
  ]
}
