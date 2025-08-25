output "aws_account_id" {
  value       = <<VALUE

  Check AWS Env:
    Project : "${var.project}" | Env: "${var.env}"
    AWS Account ID: "${data.aws_caller_identity.current.account_id}"
    AWS Account ARN: "${data.aws_caller_identity.current.arn}"
  VALUE
  description = "Show information about project, environment and account"
}

output "iam_role_ecs_execution_arn" {
  value       = module.iam_role_ecs_execution.iam_role_arn
  description = "ARN of ECS Task Execution Role - Used by ECS service to manage containers"
}

output "iam_role_ecs_task_arn" {
  value       = module.iam_role_ecs_task.iam_role_arn
  description = "ARN of ECS Task Role - Used by application code running in containers"
}

output "iam_role_lambda_ai_processor_arn" {
  value       = module.iam_role_lambda_ai_processor.iam_role_arn
  description = "ARN of Lambda AI Processor Role - Used by AI image analysis functions"
}
