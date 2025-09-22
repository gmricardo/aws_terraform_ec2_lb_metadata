terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket-gmricardo3"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "create_instance_ec2" {
  ami           = "ami-0886832e6b5c3b9e2" # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  tags = {
    Name        = "FirstInstance"
    Environment = var.environment
  }
}