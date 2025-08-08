output "aws_account_id" {
  value       = <<VALUE

  Check AWS Env:
    Project : "${var.project}" | Env: "${var.env}"
    AWS Account ID: "${data.aws_caller_identity.current.account_id}"
    AWS Account ARN: "${data.aws_caller_identity.current.arn}"
  VALUE
  description = "Show information about project, environment and account"
}

#Output modules
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of VPC"
}
output "iam_role_lambda_example_arn" {
  value       = module.iam_role_lambda_example.iam_role_arn
  description = "ARN of IAM Role Lambda Example"
}

output "s3_images_bucket_name" {
  value       = module.s3_images.s3_bucket_name
  description = "Name of S3 Bucket for Images"
}
