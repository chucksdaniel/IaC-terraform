/* Next Security group Method
  The script configures the default security group create by aws 
  at creation of VPC which is also a good practice
*/
resource "aws_default_security_group" "myapp-default-sg" {

  vpc_id = var.vpc_id

  #   ingress = [
  #   for port in [22, 80, 443, 8080, 9000]: {
  #      description = "inbound rule"
  #      from_port = port
  #      to_port = port
  #      protocol = "tcp"
  #      cidr_blocks = [var.my_ip]
  #      ipv6_cidr_blocks = []
  #      prefix_list_ids = []
  #      security_groups = []
  #      self = false
  #   }
  # ]

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.my_ip]
    # cidr_blocks = var.ingress_ip[0]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

/*
  To dynamically get ami from aws (latest image)
*/
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

/* Creating key pair with terraform */
resource "aws_key_pair" "myapp-ssh-key" {
  key_name = "server-automation-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

// Optional attribute
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.myapp-default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.myapp-ssh-key.key_name

  /* Use to associate ec2 instance with the key on the aws 
     This only works if you have created the key on aws console */
  
  # key_name = "ec2-key.pem" 

  /* user data is much more recommended to user if there is initial script */
  user_data = file("./modules/webserver/entry-script.sh")

# /*To ensure that the instance is destroyed anytime user data changes*/              
user_data_replace_on_change = true 

  tags = {
    Name: "${var.env_prefix}-server"
  }
}