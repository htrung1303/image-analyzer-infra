module "sqs_worker" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/sqs?ref=terraform-aws-sqs_v0.0.1"
  #basic
  env     = var.env
  project = var.project

  #sqs
  sqs = {
    name       = "worker"
    fifo_queue = true
    
    kms_master_key_id                 = data.terraform_remote_state.general.outputs.kms_sqs_messages_key_arn
    kms_data_key_reuse_period_seconds = 300
    
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Sid" : "AllowECSToSendMessages",
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : data.terraform_remote_state.admin.outputs.iam_role_ecs_task_arn
            },
            "Action" : "sqs:SendMessage",
            "Resource" : "*"
          },
          {
            "Sid" : "AllowLambdaToReceiveMessages", 
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : data.terraform_remote_state.admin.outputs.iam_role_lambda_ai_processor_arn
            },
            "Action" : [
              "sqs:ReceiveMessage",
              "sqs:DeleteMessage"
            ],
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
    
    kms_master_key_id                 = data.terraform_remote_state.general.outputs.kms_sqs_messages_key_arn
    kms_data_key_reuse_period_seconds = 300
  }

  #sqs-redrive-allow-policy
  sqs_redrive_allow_policy = {
    redrivePermission = "byQueue"
    sourceQueueArns   = [module.sqs_worker.sqs_arn]
  }
}
