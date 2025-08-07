module "rds_aurora" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/rds-aurora?ref=terraform-aws-rds-aurora_v0.0.2"

  project = var.project
  env     = var.env

  name = "${var.project}-${var.env}-rds-aurora"
  aurora_parameter_group = {
    family = "aurora-postgresql14"
  }
  aurora_subnet_ids = [
    data.terraform_remote_state.general.outputs.vpc_private_subnet_ids[0],
    data.terraform_remote_state.general.outputs.vpc_private_subnet_ids[1],
  ]
  aurora_cluster = {
    engine                      = "aurora-postgresql"
    engine_version              = "14.3"
    database_name               = "image-analyzer-${var.env}"
    master_username             = "${var.project}${var.env}"
    manage_master_user_password = true
    security_group_ids          = [data.terraform_remote_state.general.outputs.vpc_rds_security_group_id]
  }
  aurora_instance = {
    number         = 1
    instance_class = "db.t3.medium"
  }
  # aurora_event = {
  #   sns_topic_arn = "arn:aws:sns:ap-northeast-1:1324567890123456:anhhq-topic"
  #   event_categories = [
  #     "failover",
  #     "migration",
  #     "failure",
  #     "notification",
  #     "creation",
  #     "deletion",
  #     "maintenance",
  #     "configuration change"
  #   ]
  # }
}