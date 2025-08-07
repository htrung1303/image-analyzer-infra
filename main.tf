provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "main"
}

resource "aws_ecs_task_definition" "main" {
  family = "main"
  container_definitions = jsonencode([
    {}
  ])
}
