output "aws_account_id" {
  value       = <<VALUE
  Check AWS Env:
    Project : "${var.project}" | Env: "${var.env}"
    AWS Account ID: "${data.aws_caller_identity.current.account_id}"
    AWS Account ARN: "${data.aws_caller_identity.current.arn}"
  VALUE
  description = "Show information about project, environment and account"
}

output "sqs_worker_queue_url" {
  value       = module.sqs_worker.sqs_url
  description = "URL of SQS worker queue"
}

output "sqs_worker_queue_arn" {
  value       = module.sqs_worker.sqs_arn
  description = "ARN of SQS worker queue"
}

output "sqs_worker_dlq_queue_url" {
  value       = module.sqs_worker_dlq.sqs_url
  description = "URL of SQS worker dead letter queue"
}
