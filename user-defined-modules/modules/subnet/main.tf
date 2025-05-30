resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = var.vpc_id
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
  vpc_id = var.vpc_id

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
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}
