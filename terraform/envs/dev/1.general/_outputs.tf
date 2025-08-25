output "aws_account_id" {
  value       = <<VALUE

  Check AWS Env:
    Project : "${var.project}" | Env: "${var.env}"
    AWS Account ID: "${data.aws_caller_identity.current.account_id}"
    AWS Account ARN: "${data.aws_caller_identity.current.arn}"
  VALUE
  description = "Show information about project, environment and account"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of VPC"
}

output "s3_images_bucket_name" {
  value       = module.s3_images.s3_bucket_id
  description = "Name of S3 Bucket for Images"
}

output "s3_images_bucket_arn" {
  value       = module.s3_images.s3_bucket_arn
  description = "ARN of S3 Bucket for Images"
}

output "s3_alb_logs_bucket_name" {
  value       = module.s3_alb_logs.s3_bucket_id
  description = "Name of S3 Bucket for ALB Access Logs"
}

output "s3_alb_logs_bucket_id" {
  value       = module.s3_alb_logs.s3_bucket_id
  description = "ID of S3 Bucket for ALB Access Logs"
}

output "s3_app_logs_bucket_name" {
  value       = module.s3_app_logs.s3_bucket_id
  description = "Name of S3 Bucket for Application Logs"
}

output "s3_app_logs_bucket_arn" {
  value       = module.s3_app_logs.s3_bucket_arn
  description = "ARN of S3 Bucket for Application Logs"
}

output "s3_lambda_deployments_bucket_name" {
  value       = module.s3_lambda_deployments.s3_bucket_id
  description = "Name of S3 Bucket for Lambda Deployments"
}

output "s3_lambda_deployments_bucket_arn" {
  value       = module.s3_lambda_deployments.s3_bucket_arn
  description = "ARN of S3 Bucket for Lambda Deployments"
}

#Subnet
output "subnet_private_id" {
  value       = module.vpc.subnet_private_id
  description = "ID of Private Subnet"
}
output "subnet_public_id" {
  value       = module.vpc.subnet_public_id
  description = "ID of Public Subnet"
}

output "vpc_cidr_block" {
  value       = data.aws_vpc.main.cidr_block
  description = "CIDR block of VPC"
}

# VPC Endpoints Outputs
output "vpc_endpoint_s3_id" {
  value       = aws_vpc_endpoint.s3.id
  description = "ID of S3 VPC Endpoint"
}

output "vpc_endpoint_s3_prefix_list_id" {
  value       = aws_vpc_endpoint.s3.prefix_list_id
  description = "Prefix list ID of S3 VPC Endpoint"
}

output "vpc_endpoints_security_group_id" {
  value       = aws_security_group.vpc_endpoints.id
  description = "Security Group ID for VPC Endpoints"
}

output "ecs_web_app_security_group_id" {
  value       = aws_security_group.ecs_web_app.id
  description = "Security Group ID for ECS Web Application"
}

output "lambda_ai_processor_security_group_id" {
  value       = aws_security_group.lambda_ai_processor.id
  description = "Security Group ID for Lambda AI Processor"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "Security Group ID for Application Load Balancer"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "Security Group ID for RDS Aurora database"
}

output "kms_s3_images_key_arn" {
  value       = aws_kms_key.s3_images.arn
  description = "ARN of KMS key for S3 images encryption"
}

output "kms_sqs_messages_key_arn" {
  value       = aws_kms_key.sqs_messages.arn
  description = "ARN of KMS key for SQS messages encryption"
}

output "kms_rds_database_key_arn" {
  value       = aws_kms_key.rds_database.arn
  description = "ARN of KMS key for RDS database encryption"
}

output "kms_ecs_logs_key_arn" {
  value       = aws_kms_key.ecs_logs.arn
  description = "ARN of KMS key for ECS logs encryption"
}

output "vpc_interface_endpoints" {
  value = {
    for k, v in aws_vpc_endpoint.interface_endpoints : k => {
      id           = v.id
      dns_name     = v.dns_entry[0].dns_name
      hosted_zone_id = v.dns_entry[0].hosted_zone_id
    }
  }
  description = "Interface VPC Endpoints details"
}
