module "sqs_worker" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/sqs?ref=terraform-aws-sqs_v0.0.1"
  #basic
  env     = var.env
  project = var.project

  #sqs
  sqs = {
    name       = "worker"
    fifo_queue = true
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "example-statement-ID",
            "Effect" : "Allow",
            "Principal" : {
              "Service" : "s3.amazonaws.com"
            },
            "Action" : "sqs:SendMessage",
            "Resource" : "*"
          }
        ]
      }
    )
  }

  #sqs-redrive-policy-dlq
  sqs_redrive_policy_dlq = {
    deadLetterTargetArn = module.sqs_worker_dlq.sqs_arn
    maxReceiveCount     = 5
  }
}

module "sqs_worker_dlq" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/sqs?ref=terraform-aws-sqs_v0.0.1"
  #basic
  env     = var.env
  project = var.project

  #sqs
  sqs = {
    name       = "worker-dlq"
    fifo_queue = true
  }

  #sqs-redrive-allow-policy
  sqs_redrive_allow_policy = {
    redrivePermission = "byQueue"
    sourceQueueArns   = [module.sqs_worker.sqs_arn]
  }
}
