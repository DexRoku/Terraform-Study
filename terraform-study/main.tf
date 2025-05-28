provider "aws" {
    region = "us-east-1"
    access_key = ""
    secret_key = ""
}


resource "aws_instance" "terraform-study" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"

    tags = {
        Name = "terraform-study"
    }
}

resource "aws_vpc" "terraform-study-vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "prod-terraform-study-vpc"
    }
}

resource "aws_vpc" "terraform-study-vpc-2" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "dev-terraform-study-vpc-2"
    }
}

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.terraform-study-vpc.id
    cidr_block = "10.0.0.0/24"

    tags = {
        Name = "prod-subnet-1"
    }
}

resource "aws_subnet" "subnet-2" {
    vpc_id = aws_vpc.terraform-study-vpc-2.id
    cidr_block = "10.0.0.0/24"

    tags = {
        Name = "prod-subnet-2"
    }
}

resource "aws_key_pair" "terraform-study-key" {
  key_name   = "terraform-study-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 terraform@terra.com"
}



# create a vpc_id

resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "prod-vpc"
  }
}

# create Internet Gateway
resource "aws_internet_gateway" "prod_gateway" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "prod-gateway"
  }
}

# create a route table
resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.prod_gateway.id
  }
  tags = {
    Name = "prod-route-table"
  }