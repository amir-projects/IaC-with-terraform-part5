variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be created"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
}