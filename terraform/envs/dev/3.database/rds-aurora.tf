module "rds_aurora" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/rds-aurora?ref=terraform-aws-rds-aurora_v0.0.2"

  project = var.project
  env     = var.env

  name = "${var.project}-${var.env}-rds-aurora"
  aurora_parameter_group = {
    family = "aurora-postgresql14"
  }
  aurora_subnet_ids = data.terraform_remote_state.general.outputs.vpc_private_subnet_ids
  aurora_cluster = {
    engine                      = "aurora-postgresql"
    engine_version              = "14.3"
    database_name               = "image-analyzer-${var.env}"
    master_username             = "${var.project}${var.env}"
    manage_master_user_password = true
    security_group_ids          = [data.terraform_remote_state.general.outputs.vpc_rds_security_group_id]
    storage_encrypted = true
    kms_key_id        = data.terraform_remote_state.general.outputs.kms_rds_database_key_arn
    ca_cert_identifier = "rds-ca-2019"
    backup_retention_period = 7
    preferred_backup_window = "03:00-04:00"
    backup_kms_key_id      = data.terraform_remote_state.general.outputs.kms_rds_database_key_arn
  }
  aurora_instance = {
    number         = 1
    instance_class = "db.t3.medium"
  }
}
