terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"

    }
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "yourmentors"
}