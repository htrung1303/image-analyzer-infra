project = "image-analyzer-infra"
env     = "dev"
region  = "ap-northeast-1"

ecs = {
  api = {
    type              = "api"
    desired_count     = 1
    container_name    = "image-analyzer-api-container"
    image             = "nginx"  # Replace with your actual ECR repository URL
    tag               = "latest"
    port              = 80
    task_memory       = 2048
    task_cpu          = 512
    task_min_capacity = 1
    task_max_capacity = 3
    scale_out = {
      cooldown = 60
      metric_interval_lv1 = {
        lower_bound        = 0
        upper_bound        = 30
        scaling_adjustment = 1
      }
      metric_interval_lv2 = {
        lower_bound        = 30
        upper_bound        = null
        scaling_adjustment = 2
      }
    }
    scale_in = {
      cooldown = 300
      metric_interval_lv1 = {
        lower_bound        = -5
        upper_bound        = 0
        scaling_adjustment = -1
      }
      metric_interval_lv2 = {
        lower_bound        = null
        upper_bound        = -5
        scaling_adjustment = -2
      }
    }
  }
}

global_ips = {
  sun_dng = "203.0.113.0/24"  # Replace with actual office IP range
}
