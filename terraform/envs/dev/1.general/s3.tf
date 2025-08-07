module "s3_images" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/s3?ref=terraform-aws-s3_v0.2.1"

  project = var.project
  env     = var.env
  
  s3_bucket = {
    name = "${var.project}-${var.env}-images"
  }
}
