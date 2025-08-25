###################
# Application Load Balancer for ECS with Blue/Green Deployment
###################
module "alb_bg_ecs" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/alb-bg?ref=terraform-aws-alb_v0.0.8"
  
  project = var.project
  env     = var.env
  
  type = "ecs-bg"
  alb = {
    security_groups_id = [data.terraform_remote_state.general.outputs.alb_security_group_id]
    subnets_id         = data.terraform_remote_state.general.outputs.subnet_public_id
    access_logs = {
      bucket  = data.terraform_remote_state.general.outputs.s3_alb_logs_bucket_name
      prefix  = "alb-access-logs"
      enabled = true
    }
  }

  alb_target_group = {
    vpc_id = data.terraform_remote_state.general.outputs.vpc_id
    target_groups = [
      {
        name        = "blue"
        target_type = "ip"
        port        = 3000
        health_check = {
          port                = 3000
          path                = "/api/health"
          unhealthy_threshold = 10
          interval            = 300
          timeout             = 120
        }
      },
      {
        name        = "green"
        target_type = "ip"
        port        = 3000
        health_check = {
          port                = 3000
          path                = "/api/health"
          unhealthy_threshold = 10
          interval            = 300
          timeout             = 120
        }
      }
    ]
  }
  alb_listeners = [
    {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type    = "forward"
        forward = { target_group_arn = module.alb_bg_ecs.alb_target_group_arn["blue"] }
      }
    }
    # TODO: Add HTTPS listeners when ACM certificate is configured
    # {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
    #   certificate_arn = module.acm.acm_cert_arn
    #   default_action = {
    #     type    = "forward"
    #     forward = { target_group_arn = module.alb_bg_ecs.alb_target_group_arn["blue"] }
    #   }
    # }
  ]
  # TODO: Add listener rules when needed
  # alb_listener_rules = [
  #   {
  #     listener_arn = module.alb_bg_ecs.alb_listener_arn["80"]
  #     priority     = 100
  #     condition = [
  #       {
  #         type   = "path_pattern"
  #         values = ["/api/v1/*"]
  #       }
  #     ]
  #     action = {
  #       type = "fixed-response"
  #       fixed_response = {
  #         content_type = "application/json"
  #         status_code  = 200
  #       }
  #     }
  #   }
  # ]
}
