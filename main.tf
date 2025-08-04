module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source                = "./modules/ec2"
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnets
  rds_instance_endpoint = module.rds.rds_instance_endpoint
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  ec2_security_group_id = module.ec2.security_group_id
}

