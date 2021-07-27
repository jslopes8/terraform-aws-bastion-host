#############################################################################################################################
#
# EC2 Launch Configuration
#

#
# Bootstrap for Linux
#

data "template_file" "user_data" {
  template = file("startup-scripts/bootstrap")
}

#
# Key Pair
#

resource "aws_key_pair" "main" {
  key_name   = "bastion-hub"
  public_key = file("pki/bastion-hub.pub")
}

#
# Create Launch Configuration to ASG EC2 Instance Bastion
#

module "launch_config_bastion" {
  source = "git::https://github.com/jslopes8/terraform-aws-as-launch-config.git?ref=v2.1"

  # choose between launch configuration or launch template
  launch_configuration = "true"

  name            = "LC-${local.stack_name}"
  instance_type   = "t2.medium"

  security_groups = [ module.ec2_bastion_sg.id ]
  key_name        = aws_key_pair.main.key_name
  user_data       = data.template_file.user_data.rendered

  # this example to choose ami amazon linux 2
  # outro argumento valido é o ami_id, mas conflita com o choose_ami
  choose_ami = [
    {
      most_recent = "true"
      owners      = [ "amazon" ]
      filter      = [
        {
          name = "owner-alias"
          values = [ "amazon" ]
        },
        {
          name = "name"
          values = ["amzn2-ami-hvm*"]
        }
      ]
    }
  ]

  # EBS Block Device - OS Volume
  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "40"
      delete_on_termination = "true"
      encrypted             = "true"
    }
  ]
}