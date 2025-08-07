module "ecs_api" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/ecs?ref=terraform-aws-ecs_v0.0.1"
  #basic
  env     = var.env
  project = var.project

  #ecs-cluster
  ecs_cluster_name = var.ecs.api.type
  #ecs-service
  ecs_services = [
    {
      name                  = var.ecs.api.type
      task_definition_arn   = module.ecs_api.ecs_task_definition_arn[var.ecs.api.type]
      desired_count         = var.ecs.api.desired_count
      security_groups_id    = [data.terraform_remote_state.general.outputs.ecs_web_app_security_group_id]
      subnets_id            = data.terraform_remote_state.general.outputs.vpc_private_subnet_ids
      deployment_controller = "CODE_DEPLOY"
      load_balancer = {
        target_group_arn = module.alb_bg_ecs.alb_target_group_arn["blue"]
        container_name   = var.ecs.api.container_name
        container_port   = var.ecs.api.port
      }
    }
  ]
  #ecs-task-definition
  ecs_task_definition = {
    execution_role_arn = data.terraform_remote_state.admin.outputs.iam_role_ecs_execution_arn
    task_definitions = [
      {
        name          = var.ecs.api.type
        total_memory  = var.ecs.api.task_memory
        total_cpu     = var.ecs.api.task_cpu
        task_role_arn = data.terraform_remote_state.admin.outputs.iam_role_ecs_task_arn
        container_definitions = {
          template = "${path.module}/ecs-task-definition/api.json"
          vars = {
            name           = var.ecs.api.container_name
            image          = var.ecs.api.image
            tag            = var.ecs.api.tag
            containerPort  = var.ecs.api.port
            hostPort       = var.ecs.api.port
            env            = var.env
            awslogs_group  = data.terraform_remote_state.monitoring.outputs.cloudwatch_log_group_ecs_cluster_name
            awslogs_region = var.region
          }
        }
      }
    ]
  }
}
