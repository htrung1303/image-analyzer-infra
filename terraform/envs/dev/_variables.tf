variable "project" {
  description = "Name of project"
  type        = string
}
variable "env" {
  description = "Name of project environment"
  type        = string
}
variable "region" {
  description = "Region of environment"
  type        = string
}

variable "ecs" {
  description = "ECS configuration"
  type        = any
}

variable "global_ips" {
  description = "Global IP ranges for access control"
  type        = any
}
