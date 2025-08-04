variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be created"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block assigned to the VPC"
}

variable "ec2_security_group_id" {
  type        = string
  description = "The ID of the security group to associate with the EC2 instance"
}