# Lambda Layer for OpenAI dependencies
resource "aws_lambda_layer_version" "openai_layer" {
  filename            = data.archive_file.lambda_layer_zip.output_path
  layer_name          = "${var.project}-${var.env}-openai-dependencies"
  description         = "OpenAI SDK and dependencies for image analysis"
  compatible_runtimes = ["python3.9"]
  source_code_hash    = data.archive_file.lambda_layer_zip.output_base64sha256
}

# Lambda AI Processor - Processes images from SQS worker queue
module "lambda_ai_processor" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/lambda?ref=terraform-aws-lambda_v0.0.5"
  
  #basic
  project = var.project
  env     = var.env
  region  = var.region
  service = "ai-processor"

  #lambda-zip
  lambda_zip_python = {
    code_path     = "./lambda-function/ai-processor"
    code_zip_path = "./lambda-function"
    code_zip_name = "ai-processor"
  }
  
  #lambda
  lambda_function = {
    name    = "ai-processor"
    role    = data.terraform_remote_state.admin.outputs.iam_role_lambda_ai_processor_arn
    runtime = "python3.9"
    timeout = 300  # 5 minutes for image processing
    memory_size = 1024
    
    vpc_config = {
      subnet_ids         = data.terraform_remote_state.general.outputs.subnet_private_id
      security_group_ids = [data.terraform_remote_state.general.outputs.lambda_ai_processor_security_group_id]
    }
    
    layers = [aws_lambda_layer_version.openai_layer.arn]
    
    environment = {
      variables = {
        S3_IMAGES_BUCKET = data.terraform_remote_state.general.outputs.s3_images_bucket_name
        SQS_RESULTS_QUEUE_URL = data.terraform_remote_state.messaging.outputs.sqs_results_queue_url
        AWS_REGION = var.region
        OPENAI_API_KEY = var.openai_api_key
      }
    }
  }
  
  # SQS Event Source Mapping - Triggers Lambda when messages arrive in worker queue
  lambda_function_sqs = [
    {
      arn        = data.terraform_remote_state.messaging.outputs.sqs_worker_queue_arn
      name       = "sqs-worker-trigger"
      batch_size = 1  # Process one message at a time for image analysis
      maximum_batching_window_in_seconds = 0
    }
  ]
}
