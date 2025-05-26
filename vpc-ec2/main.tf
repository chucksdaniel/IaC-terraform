provider "aws" {
  region = "eu-central-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable avail_zone-2 {}
variable env_prefix {}
variable ingress_ip {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable private_key_location {}
variable subnet_2_cidr_block {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}


resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

/* List all availability zone */
data "aws_availability_zones" "available" {
  filter {
    name = "opt-in-status"
    values = ["opt-in-not-required"] # Optional: Filters for AZs that don't require opt-in
  }
}

/** Method one
 Creating interner gateway for the vpc
 And associate it to a subnet
**/
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

/** Method 2 
 To use the default route table aws created for us
 Instead of creating a new route table. One of the requirement is that 
 the vpc and route tablr exist 3 and by default the rtb is associated to the subnet
**/
resource "aws_default_route_table" "myapp-default-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

/* Next Security group Method
  The script configures the default security group create by aws 
  at creation of VPC which is also a good practice
*/
resource "aws_default_security_group" "myapp-default-sg" {

  vpc_id = aws_vpc.myapp-vpc.id

  ingress = [
    for port in [22, 80, 443, 8080, 9000]: {
       description = "inbound rule"
       from_port = port
       to_port = port
       protocol = "tcp"
       cidr_blocks = [var.my_ip]
       ipv6_cidr_blocks = []
       prefix_list_ids = []
       security_groups = []
       self = false
    }
  ]

  # ingress {
  #   from_port = 22
  #   to_port = 22
  #   protocol = "TCP"
  #   cidr_blocks = [var.my_ip]
  #   # cidr_blocks = var.ingress_ip[0]
  # }

  # ingress {
  #   from_port = 8080
  #   to_port = 8080
  #   protocol = "TCP"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" // No restriction
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = [] // to allow access to vpc end point not required though
  }

  tags = {
    Name: "${var.env_prefix}-default-sg"
  }
}

##commands

# terraform init
# terraform plan
# terraform apply --auto-approve
# terraform destroy --auto-approve