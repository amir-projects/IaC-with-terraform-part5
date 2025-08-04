locals {
  tags = {
    Project     = "three-tier-platform"
    Environment = "prod"
  }
}


module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "rds-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id
  tags        = local.tags

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = var.ec2_security_group_id
      description              = "Allow MySQL from EC2 Instance"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

/*
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  identifier                = "three-tier-platform-database"
  engine                    = "mysql"
  engine_version            = "8.0"
  family                    = "mysql8.0"
  major_engine_version      = "8.0"
  instance_class            = "db.t3.micro"
  create_db_parameter_group = false
  allocated_storage         = 10
  max_allocated_storage     = 100
  db_name                   = "crud_operations"
  username                  = "admin"
  # password                    = "User12345random25!"
  port                = 3306
  multi_az            = false
  deletion_protection = false
  # manage_master_user_password = false
  create_db_subnet_group = true
  subnet_ids             = var.private_subnets
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.rds-security-group.security_group_id]
}
*/