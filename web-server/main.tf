terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.0"
}

resource "aws_instance" "app" {
  instance_type     = "t2.micro"
  availability_zone = "eu-west-2a"
  ami               = "ami-01a6e31ac994bbc09"
  tags              = local.common_tags

  user_data = <<-EOF
              #!/bin/bash
              sudo service apache2 start
              EOF
}
