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
    cidr_block = "10.0.1.0/16"

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
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "prod-subnet-2"
    }
}