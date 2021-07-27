#############################################################################
#
# Data Source - Query's for VPC, Subnet's...
#

# Selected VPC Id
data "aws_vpc" "selected" {
  id  = local.vpc_id
}

#
# Query for Subnets Private
#

data "aws_subnet_ids" "sn_private" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name    = "tag:Name"
    values  = [ "*Priv*" ]
  }
}

#
# Query for Subnets Public
#

data "aws_subnet_ids" "sn_public" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name    = "tag:Name"
    values  = [ "*Pub*" ]
  }
}