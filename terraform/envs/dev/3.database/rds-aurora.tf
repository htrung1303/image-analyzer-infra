module "rds_aurora" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/rds-aurora?ref=terraform-aws-rds_v0.0.2"

  project = var.project
  env     = var.env

  name = "${var.project}-${var.env}-rds-aurora"
  aurora_parameter_group = {
    family = "aurora-postgresql14"
  }
  aurora_subnet_ids = data.terraform_remote_state.general.outputs.subnet_private_id
  aurora_cluster = {
    engine                      = "aurora-postgresql"
    engine_version              = "14.3"
    database_name               = "image-analyzer-${var.env}"
    master_username             = "${var.project}${var.env}"
    manage_master_user_password = true
    security_group_ids          = [data.terraform_remote_state.general.outputs.rds_security_group_id]
    storage_encrypted = true
    kms_key_id        = data.terraform_remote_state.general.outputs.kms_rds_database_key_arn
    backup_kms_key_id      = data.terraform_remote_state.general.outputs.kms_rds_database_key_arn
  }
  aurora_instance = {
    number         = 1
    instance_class = "db.t3.medium"
  }
}
