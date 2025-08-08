module "cloudwatch_log_group_ecs_cluster" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/cloudwatch-log-group?ref=terraform-aws-cloudwatch-log-group_v0.0.1"
  #cloudwatch-log-group
  name              = "${var.project}-${var.env}-${var.region}-ecs-cluster"
  retention_in_days = 90
}
