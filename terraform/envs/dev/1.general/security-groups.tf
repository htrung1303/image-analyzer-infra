resource "aws_security_group" "ecs_web_app" {
  name_prefix = "${var.project}-${var.env}-ecs-web-app-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for ECS web application containers"

  ingress {
    description     = "HTTP from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "HTTPS to internet (ECR, external APIs)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP to internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "ECS to RDS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds.id]
  }

  tags = {
    Name = "${var.project}-${var.env}-ecs-web-app-sg"
  }
}

resource "aws_security_group" "lambda_ai_processor" {
  name_prefix = "${var.project}-${var.env}-lambda-ai-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Lambda AI processing functions"

  egress {
    description     = "HTTPS to VPC Endpoints"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.vpc_endpoints.id]
  }

  tags = {
    Name = "${var.project}-${var.env}-lambda-ai-sg"
  }
}

resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_web_app.id
  security_group_id        = aws_security_group.rds.id
  description              = "Allow ECS web app to connect to RDS"
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.project}-${var.env}-alb-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Application Load Balancer"

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-alb-sg"
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${var.project}-${var.env}-rds-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for RDS Aurora database"

  tags = {
    Name = "${var.project}-${var.env}-rds-sg"
  }
}

