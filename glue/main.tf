terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.0"
}