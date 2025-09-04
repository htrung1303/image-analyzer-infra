module "cloudwatch_log_group_ecs_cluster" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/cloudwatch-log-group?ref=terraform-aws-cloudwatch_v0.1.0"
  #cloudwatch-log-group
  name              = "${var.project}-${var.env}-${var.region}-ecs-cluster"
  retention_in_days = 90
}
