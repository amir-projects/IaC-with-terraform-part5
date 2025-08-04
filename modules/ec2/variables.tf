variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be created"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "rds_instance_endpoint" {
  description = "The endpoint address of the RDS instance"
  type        = string
}