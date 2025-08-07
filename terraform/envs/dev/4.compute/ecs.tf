module "ecs_appautoscaling_api" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/ecs-appautoscaling?ref=terraform-aws-ecs_v0.0.1"
  #basic
  project = var.project
  env     = var.env

  #ecs-appautoscaling
  ecs_appautoscaling_target = {
    cluster_name = "${var.project}-${var.env}-ecs-cluster"
    service_name = "${var.project}-${var.env}-ecs-service"
    min_capacity = var.ecs.api.task_min_capacity
    max_capacity = var.ecs.api.task_max_capacity
  }
  ecs_appautoscaling_policies = [
    {
      name     = "scale-out-CPUUtilization"
      cooldown = var.ecs.api.scale_out.cooldown
      step_adjustments = [
        {
          metric_interval_lower_bound = var.ecs.api.scale_out.metric_interval_lv1.lower_bound
          metric_interval_upper_bound = var.ecs.api.scale_out.metric_interval_lv1.upper_bound
          scaling_adjustment          = var.ecs.api.scale_out.metric_interval_lv1.scaling_adjustment
        },
        {
          metric_interval_lower_bound = var.ecs.api.scale_out.metric_interval_lv2.lower_bound
          metric_interval_upper_bound = var.ecs.api.scale_out.metric_interval_lv2.upper_bound
          scaling_adjustment          = var.ecs.api.scale_out.metric_interval_lv2.scaling_adjustment
        }
      ]
    },
    {
      name     = "scale-in-CPUUtilization"
      cooldown = var.ecs.api.scale_in.cooldown
      step_adjustments = [
        {
          metric_interval_lower_bound = var.ecs.api.scale_in.metric_interval_lv1.lower_bound
          metric_interval_upper_bound = var.ecs.api.scale_in.metric_interval_lv1.upper_bound
          scaling_adjustment          = var.ecs.api.scale_in.metric_interval_lv1.scaling_adjustment
        },
        {
          metric_interval_lower_bound = var.ecs.api.scale_in.metric_interval_lv2.lower_bound
          metric_interval_upper_bound = var.ecs.api.scale_in.metric_interval_lv2.upper_bound
          scaling_adjustment          = var.ecs.api.scale_in.metric_interval_lv2.scaling_adjustment
        }
      ]
    }
  ]
}
