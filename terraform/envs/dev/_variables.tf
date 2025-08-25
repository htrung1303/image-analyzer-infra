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
  type        = map(any)
}

variable "openai_api_key" {
  description = "OpenAI API key for image analysis"
  type        = string
  sensitive   = true
}
