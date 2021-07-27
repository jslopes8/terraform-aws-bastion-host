#############################################################################################################################
#
# EC2 Elastic Load Balance
#

module "elb_bastion" {
  source = "git@github.com:jslopes8/terraform-aws-lb-elb.git?ref=v1.7.2"

  name                        = lower("${local.stack_name}")
  cross_zone_load_balancing   = "true"
  idle_timeout                = "4000"
  connection_draining         = "true"
  connection_draining_timeout = "30"

  security_groups = [ module.elb_remote_ssh.id ]
  subnets         = [ 
    tolist(data.aws_subnet_ids.sn_public.ids)[0], 
    tolist(data.aws_subnet_ids.sn_public.ids)[1] 
  ]

  listener = [{
    instance_port     = "22"
    instance_protocol = "tcp"
    lb_port           = "22"
    lb_protocol       = "tcp"
  }]

  health_check = {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    timeout             = "3"
    target              = "tcp:22"
    interval            = "5"
  }

  default_tags = local.default_tags
}