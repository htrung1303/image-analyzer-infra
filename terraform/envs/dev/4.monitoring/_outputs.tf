output "aws_account_id" {
  value       = <<VALUE
  Check AWS Env:
    Project : "${var.project}" | Env: "${var.env}"
    AWS Account ID: "${data.aws_caller_identity.current.account_id}"
    AWS Account ARN: "${data.aws_caller_identity.current.arn}"
  VALUE
  description = "Show information about project, environment and account"
}

output "cloudwatch_log_group_ecs_cluster_name" {
  value       = module.cloudwatch_log_group_ecs_cluster.name
  description = "Name of Cloudwatch Log Group for ECS Cluster"
}
