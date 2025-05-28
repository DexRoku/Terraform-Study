provider "aws" {
    region = "us-east-1"
    access_key = ""
    secret_key = "+"
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


resource "aws_key_pair" "terraform-study-key" {
  key_name   = "terraform-study-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 terraform@terra.com"
}



# 1. create a vpc_id

resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "prod-vpc"
  }
}

# 2. create Internet Gateway
resource "aws_internet_gateway" "prod_gateway" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "prod-gateway"
  }
}

# 3. create a route table
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

}
# 4. Create a subnet
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod_vpc.id    # use prod_vpc here
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "prod-subnet-1"
  }
}

# 5. Associate the route table with the subnet
resource "aws_route_table_association" "prod_route_table_association" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod_route_table.id
}

# 6. Create a security group
resource "aws_security_group" "prod_security_group" {
  name        = "prod-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 9- Create an EC2 instance 
resource "aws_instance" "prod_ec2_instance" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet-1.id
  vpc_security_group_ids = [aws_security_group.prod_security_group.id]
  key_name      = aws_key_pair.terraform-study-key.key_name

  tags = {
    Name = "prod-ec2-instance"
  }

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World!" > /var/www/html/index.html
                systemctl start httpd
                systemctl enable httpd
                EOF

}