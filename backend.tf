terraform {
  backend "s3" {
    bucket  = "yourmentors-terraform-state-files"
    key     = "terraform.tfstate"
    region  = "ap-southeast-1"
    profile = "badhansaha"
    encrypt = true
  }
}