locals {
  tags = {
    Project     = "three-tier-platform"
    Environment = "production"
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = "three-tier-platform-vpc"
  cidr = "10.0.0.0/16"

  azs                           = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets               = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets                = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  create_database_subnet_group  = false
  enable_nat_gateway            = true
  single_nat_gateway            = true
  one_nat_gateway_per_az        = false
  manage_default_security_group = false
  tags                          = local.tags
}

