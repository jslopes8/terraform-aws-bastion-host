#############################################################################################################################
#
# EC2 AutoScalling Group
#

module "autoscaling_bastion" {
  source = "git::https://github.com/jslopes8/terraform-aws-as-asgroup.git?ref=v2.0.7"

  asg_name  = "${local.stack_name}-AS"
  min_size  = 1
  max_size  = 1

  vpc_zone_identifier     = [ 
    tolist(data.aws_subnet_ids.sn_priv.ids)[0],
    tolist(data.aws_subnet_ids.sn_priv.ids)[1], 
  ]
  health_check_type       = "ELB"
  launch_configuration    = module.launch_config_bastion.name
  load_balancers          = [ module.elb_bastion.id ]

  # Scaling Policy
  auto_scaling_policy_up = [
    {
      name                = "${local.stack_name}-Policy-UP"
      scaling_adjustment  = "1"
      adjustment_type     = "ChangeInCapacity"
      cooldown            = "300"
      policy_type         = "SimpleScaling"
      alarm_name          = "${local.stack_name}-Metric-Alarm-UP"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = "2"
      namespace           = "AWS/EC2"
      metric_name         = "CPUUtilization"
      period              = "300"
      statistic           = "Average"
      threshold           = "60"
    }
  ]

  auto_scaling_policy_down = [
    {
      name                = "${local.stack_name}-Policy-DOWN"
      scaling_adjustment  = "-1"
      adjustment_type     = "ChangeInCapacity"
      cooldown            = "300"
      policy_type         = "SimpleScaling"
      alarm_name          = "${local.stack_name}-Metric-Alarm-DOWN"
      comparison_operator = "LessThanOrEqualToThreshold"
      evaluation_periods  = "2"
      namespace           = "AWS/EC2"
      metric_name         = "CPUUtilization"
      period              = "120"
      statistic           = "Average"
      threshold           = "5"
    }
  ]

  default_tags = [
    {
      "key"                 = "ApplicationRole"
      "value"               = "Bastion Host"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Environment"
      "value"               = "Production"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "CostCenter"
      "value"               = "12345678"
      "propagate_at_launch" = true
    }
  ]
}