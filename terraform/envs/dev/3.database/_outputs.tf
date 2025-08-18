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
output "rds_aurora_cluster_name" {
  value       = module.rds_aurora.aurora_cluster_name
  description = "ID of RDS Aurora Cluster"
}
output "rds_aurora_cluster_endpoint" {
  value       = module.rds_aurora.aurora_cluster_endpoint
  description = "Endpoint of RDS Aurora Cluster"
}
