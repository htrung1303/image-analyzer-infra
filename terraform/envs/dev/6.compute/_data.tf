data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Lambda Layer for OpenAI dependencies
# Data source to create a zip file of the layer dependencies
data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-layer/openai"
  output_path = "${path.module}/lambda-layer/openai-layer.zip"
}
