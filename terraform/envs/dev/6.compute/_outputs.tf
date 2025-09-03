output "aws_account_id" {
  value       = <<VALUE
  Check AWS Env:
    Project : "${var.project}" | Env: "${var.env}"
    AWS Account ID: "${data.aws_caller_identity.current.account_id}"
    AWS Account ARN: "${data.aws_caller_identity.current.arn}"
  VALUE
  description = "Show information about project, environment and account"
}

output "lambda_ai_processor_function_name" {
  value       = module.lambda_ai_processor.lambda_function_name
  description = "Name of the Lambda AI processor function"
}

output "lambda_ai_processor_function_arn" {
  value       = module.lambda_ai_processor.lambda_function_arn
  description = "ARN of the Lambda AI processor function"
}
