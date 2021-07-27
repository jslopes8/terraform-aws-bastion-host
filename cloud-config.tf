#############################################################################################################################
#
# Provider - AWS
#

provider "aws" {
  region  = "us-east-1"

  ## AWS Profile Master Account que permite o Assume Role
  profile = "aws-profile-master"

  ## IAM Role na linked account
  assume_role {
    role_arn    = "arn:aws:iam::AWS-ID-ACCOUNT:role/NomeRoleAccess"
  }
}

terraform {
  backend "s3" {
    profile                     = "aws-profile-master"
    bucket                      = "s3-bucket-tfstate"
    key                         = "edp-acc-master/infra-bastion/terraform.tfstate"
    region                      = "us-east-1"
    encrypt                     = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
}

#############################################################################################################################
#
# Variavies de Input Global
#

locals {
  vpc_id = "vpc-XYXYXYXYXYXYXYXYXYX"

  stack_name = "Bastion-Host"
  default_tags = {
    Environment 	  = "Production"
    ApplicationRole = "Bastion Host"
    CostCenter      = "12345678"
  }
}