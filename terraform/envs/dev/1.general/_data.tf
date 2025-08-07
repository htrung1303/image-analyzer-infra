data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_vpc" "main" {
  id = module.vpc.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_route_tables" "private" {
  vpc_id = module.vpc.vpc_id
  
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}
