###################
# ECS Task Execution Role - Allows ECS to manage containers
# This role is used by ECS service to pull images, send logs, and access secrets
###################

# ECS Task Execution Role - Used by ECS service itself
module "iam_role_ecs_execution" {
  source = "git@github.com:framgia/sun-infra-iac.git//modules/iam-role?ref=terraform-aws-iam_v0.1.2"
  
  env     = var.env
  project = var.project
  service = "ecs"

  name               = "ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs_tasks.json
  
  iam_custom_policy = {
    template = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowECRAccess",
          "Effect" : "Allow",
          "Action" : [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability", 
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "AllowCloudWatchLogs",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:${var.region}:*:log-group:/ecs/${var.project}-${var.env}-*"
        },
        {
          "Sid" : "AllowSecretsAccess",
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : "arn:aws:secretsmanager:${var.region}:*:secret:${var.project}-${var.env}-*"
        }
      ]
    })
  }
}

module "iam_role_ecs_task" {
  source = "git@github.com:framgia/sun-infra-iac.git//modules/iam-role?ref=terraform-aws-iam_v0.1.2"
  
  env     = var.env
  project = var.project
  service = "ecs"

  name               = "ecs-task"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs_tasks.json
  
  iam_custom_policy = {
    template = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowS3ImageAccess",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ],
          "Resource" : [
            "arn:aws:s3:::${var.project}-${var.env}-images/*"
          ]
        },
        {
          "Sid" : "AllowS3ListBucket",
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket"
          ],
          "Resource" : [
            "arn:aws:s3:::${var.project}-${var.env}-images"
          ]
        },
        {
          "Sid" : "AllowSQSMessaging",
          "Effect" : "Allow",
          "Action" : [
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
          ],
          "Resource" : [
            "arn:aws:sqs:${var.region}:*:${var.project}-${var.env}-*"
          ]
        },
        {
          "Sid" : "AllowSecretsAccess",
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : [
            "arn:aws:secretsmanager:${var.region}:*:secret:${var.project}-${var.env}-*"
          ]
        },
        {
          "Sid" : "AllowKMSDecryption",
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ],
          "Resource" : [
            "arn:aws:kms:${var.region}:*:key/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "kms:ViaService" : [
                "s3.${var.region}.amazonaws.com",
                "sqs.${var.region}.amazonaws.com"
              ]
            }
          }
        }
      ]
    })
  }
}

data "aws_iam_policy_document" "assume_role_ecs_tasks" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

module "iam_role_lambda_ai_processor" {
  source = "git@github.com:framgia/sun-infra-iac.git//modules/iam-role?ref=terraform-aws-iam_v0.1.2"
  
  env     = var.env
  project = var.project
  service = "lambda"

  name               = "lambda-ai-processor"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  
  iam_custom_policy = {
    template = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowS3ImageAccess",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : [
            "arn:aws:s3:::${var.project}-${var.env}-images/*"
          ]
        },
        {
          "Sid" : "AllowSQSProcessing",
          "Effect" : "Allow",
          "Action" : [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:SendMessage",
            "sqs:GetQueueAttributes"
          ],
          "Resource" : [
            "arn:aws:sqs:${var.region}:*:${var.project}-${var.env}-*"
          ]
        },
        {
          "Sid" : "AllowCloudWatchLogs",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:${var.region}:*:log-group:/aws/lambda/${var.project}-${var.env}-ai-*"
        },
        {
          "Sid" : "AllowKMSForEncryption",
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ],
          "Resource" : [
            "arn:aws:kms:${var.region}:*:key/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "kms:ViaService" : [
                "s3.${var.region}.amazonaws.com",
                "sqs.${var.region}.amazonaws.com"
              ]
            }
          }
        }
      ]
    })
  }
}


