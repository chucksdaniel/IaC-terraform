/*
  To dynamically get ami from aws (latest image)
*/
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
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
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.myapp-default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = false
  key_name = aws_key_pair.myapp-ssh-key.key_name

  /* Use to associate ec2 instance with the key on the aws 
     This only works if you have created the key on aws console */
  
  # key_name = "ec2-key.pem" 

  /* user data is much more recommended to user if there is initial script */
  user_data = file("entry-script.sh")


# /*To ensure that the instance is destroyed anytime user data changes*/              
user_data_replace_on_change = true 

  tags = {
    Name: "${var.env_prefix}-server"
  }
}

# Create an Elastic IP
resource "aws_eip" "myapp_eip" {
  domain = "vpc"
}

# Associate Elastic IP with the EC2 instance
resource "aws_eip_association" "myapp_eip_assoc" {
  instance_id   = aws_instance.myapp-server.id
  allocation_id = aws_eip.myapp_eip.id
}