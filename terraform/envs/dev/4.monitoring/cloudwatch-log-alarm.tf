module "sns_cloudwatch_alarm" {
  source = "git@github.com:framgia/sun-infra-iac.git//modules/sns?ref=terraform-aws-sns_v0.0.1"
  #basic
  env     = var.env
  project = var.project
  region  = var.region

  #sns
  sns_topic_name = "cloudwatch-alarm"
  service        = "cloudwatch"
}

module "cloudwatch_alarm_ecs" {
  source = "git@github.com:sun-asterisk-internal/sun-infra-iac.git//modules/aws/cloudwatch-alarm?ref=terraform-aws-cloudwatch_v0.1.0"
  #basic
  env     = var.env
  project = var.project

  #cloudwatch-alarm
  service = "ecs"
  type    = "general"
  cloudwatch_alarms = [
    {
      name                = "HIGH-CPUUtilization"
      metric_name         = "CPUUtilization"
      namespace           = "AWS/ECS"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      statistic           = "Average"
      threshold           = 70
      unit                = "%"
      datapoints_to_alarm = 1
      evaluation_periods  = 1
      period              = 300
      dimensions = {
        ClusterName = "${var.project}-${var.env}-ecs-cluster"
        ServiceName = "${var.project}-${var.env}-ecs-service"
      }
      alarm_actions = [module.sns_cloudwatch_alarm.sns_topic_arn]
      ok_actions    = [module.sns_cloudwatch_alarm.sns_topic_arn]
    }
  ]
}
