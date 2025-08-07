
resource "aws_kms_key" "s3_images" {
  description             = "KMS key for encrypting user images and analysis results in S3"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 Service"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.${var.region}.amazonaws.com"
          }
        }
      },
      {
        Sid    = "Allow ECS and Lambda to use the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-${var.env}-ecs-task",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-${var.env}-lambda-ai-processor"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.env}-s3-images-key"
  }
}

resource "aws_kms_alias" "s3_images" {
  name          = "alias/${var.project}-${var.env}-s3-images"
  target_key_id = aws_kms_key.s3_images.key_id
}

resource "aws_kms_key" "sqs_messages" {
  description             = "KMS key for encrypting SQS messages containing image processing requests"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow SQS Service"
        Effect = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "sqs.${var.region}.amazonaws.com"
          }
        }
      },
      {
        Sid    = "Allow ECS and Lambda to use the key"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-${var.env}-ecs-task",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project}-${var.env}-lambda-ai-processor"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "sqs.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.env}-sqs-messages-key"
  }
}

resource "aws_kms_alias" "sqs_messages" {
  name          = "alias/${var.project}-${var.env}-sqs-messages"
  target_key_id = aws_kms_key.sqs_messages.key_id
}

resource "aws_kms_key" "rds_database" {
  description             = "KMS key for encrypting RDS Aurora database containing user data and analysis results"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "rds.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.env}-rds-database-key"
  }
}

resource "aws_kms_alias" "rds_database" {
  name          = "alias/${var.project}-${var.env}-rds-database"
  target_key_id = aws_kms_key.rds_database.key_id
}

resource "aws_kms_key" "ecs_logs" {
  description             = "KMS key for encrypting ECS and Lambda CloudWatch logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project}-${var.env}-*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-${var.env}-ecs-logs-key"
  }
}

resource "aws_kms_alias" "ecs_logs" {
  name          = "alias/${var.project}-${var.env}-ecs-logs"
  target_key_id = aws_kms_key.ecs_logs.key_id
}
