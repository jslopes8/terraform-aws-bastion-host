#############################################################################################################################
#
# EC2 Security Group
#

#
# Security Group for Load Balance
#

module "elb_remote_ssh" {
  source = "git::https://github.com/jslopes8/terraform-aws-networking-security-group.git?ref=v2.2"

  name    = "ELB-${local.stack_name}"
  vpc_id  = data.aws_subnet_ids.sn_public.id
  rule    = [
    {
      description = "Bastion SSH Remote"
      type        = "ingress"
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }
  ]

  default_tags = local.default_tags
}

#
# Security Group for Launch Config - EC2 Instance Bastion
#

module "ec2_bastion_sg" {
  source = "git@github.com:jslopes8/terraform-aws-networking-security-group.git?ref=v2.2"

  name    = "EC2-${local.stack_name}"
  vpc_id  = data.aws_subnet_ids.sn_private.id

  rule = [
    {
      description   = "EC2_RemoteSSH_by_ELB"
      type          = "ingress"
      from_port     = "22"
      to_port       = "22"
      protocol      = "tcp"
      sec_group_id  = module.elb_remote_ssh.id
    },
    {
      description = "EC2_RemoteSSH_AccessInternal"
      type        = "ingress"
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      cidr_blocks = [ data.aws_vpc.selected.cidr_block ]
    },
    {
      description = "EC2_RemoteICMP_AccessInternal"
      type        = "ingress"
      from_port   = "0"
      to_port     = "-1"
      protocol    = "icmp"
      cidr_blocks = [ data.aws_vpc.selected.cidr_block ]
    }
  ]

  default_tags = local.default_tags
}