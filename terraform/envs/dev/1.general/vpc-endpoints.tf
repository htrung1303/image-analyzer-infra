resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project}-${var.env}-vpc-endpoints-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for VPC endpoints"
  
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project}-${var.env}-vpc-endpoints-sg"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.aws_route_tables.private.ids
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project}-${var.env}-*",
          "arn:aws:s3:::${var.project}-${var.env}-*/*"
        ]
      }
    ]
  })
  
  tags = {
    Name = "${var.project}-${var.env}-s3-endpoint"
  }
}

locals {
  interface_endpoints = {
    "sqs" = {
      service_name = "com.amazonaws.${var.region}.sqs"
      description  = "SQS - ECS sends image analysis requests, Lambda sends results back"
      use_case     = "interface"
    }
    "sns" = {
      service_name = "com.amazonaws.${var.region}.sns"
      description  = "SNS - Event notifications for image processing status"
      use_case     = "interface"
    }

    "logs" = {
      service_name = "com.amazonaws.${var.region}.logs"
      description  = "CloudWatch Logs - Required for ECS and Lambda logging"
      use_case     = "support"
    }

    "secretsmanager" = {
      service_name = "com.amazonaws.${var.region}.secretsmanager"
      description  = "Secrets Manager - Database credentials and AI service API keys"
      use_case     = "support"
    }

    "kms" = {
      service_name = "com.amazonaws.${var.region}.kms"
      description  = "KMS - Encryption for S3 user images, SQS messages, and analysis results"
      use_case     = "support"
    }

    "ssm" = {
      service_name = "com.amazonaws.${var.region}.ssm"
      description  = "Systems Manager - Image processing configuration parameters"
      use_case     = "support"
    }
  }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each = local.interface_endpoints
  
  vpc_id              = module.vpc.vpc_id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private.ids
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  
  private_dns_enabled = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalVpc" = module.vpc.vpc_id
          }
        }
      }
    ]
  })
  
  tags = {
    Name        = "${var.project}-${var.env}-${each.key}-endpoint"
    Description = each.value.description
  }
}
