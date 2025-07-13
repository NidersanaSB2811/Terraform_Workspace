#This Terraform Code Deploys Basic VPC Infra.
#provider configuration

# access_key = "${var.aws_access_key}"
# secret_key = "${var.aws_secret_key}"
# the above both we should use if we dont have aws cli and if we have not done "aws configue"

# provider "aws" {
#   access_key = "${var.aws_access_key}"
#   secret_key = "${var.aws_secret_key}"
#   region = var.aws_region
# }

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
#creating s3 bucket
#that is the terraform wants the s3 available to store state even before terraform init , so only manual s3 creation works 

# resource "aws_s3_bucket" "example" {
#   bucket = "vpc2-state-bucket"

#   tags = {
#     Name        = "vpc2-state-bucket"
#   }
# }

#for saving statefiles creating s3 bucket 
terraform {
  backend "s3" {
    bucket = "vpc2-state-bucket-try"
    key    = "state1"
    region = "us-east-1"
  }
}

#vpc
resource "aws_vpc" "Vpc2" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name  = "${var.vpc_name}"
    Owner = "Saikiran"
  }
}

#igw
resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.Vpc2.id
  tags = {
    Name = "${var.IGW_name}"
  }
}

#public subnet 1
resource "aws_subnet" "subnet1-public" {
  vpc_id            = aws_vpc.Vpc2.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.public_subnet1_name}"
  }
}

#public subnet 2
resource "aws_subnet" "subnet2-public" {
  vpc_id            = aws_vpc.Vpc2.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.public_subnet2_name}"
  }
}

#public subnet 3
resource "aws_subnet" "subnet3-public" {
  vpc_id            = aws_vpc.Vpc2.id
  cidr_block        = var.public_subnet3_cidr
  availability_zone = "us-east-1c"

  tags = {
    Name = "${var.public_subnet3_name}"
  }

}


#route table 
resource "aws_route_table" "terraform-public" {
  vpc_id = aws_vpc.Vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw2.id
  }

  tags = {
    Name = "${var.Main_Routing_Table}"
  }
}

#associating route table to subnet 1
resource "aws_route_table_association" "terraform-public" {
  subnet_id      = aws_subnet.subnet1-public.id
  route_table_id = aws_route_table.terraform-public.id
}

#security group and nacl
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.Vpc2.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


