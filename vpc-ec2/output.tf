output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image
}
output "dev-vpc-id" {
  value = aws_vpc.myapp-vpc.id
}

output "dev-vpc" {
  value = aws_vpc.myapp-vpc
}

output "dev-subnet-id-1" {
  value = aws_subnet.myapp-subnet-1.id
}

output "dev-subnet-1" {
  value = aws_subnet.myapp-subnet-1
}

output "list_of_az" {
  value = data.aws_availability_zones.available.names
}

output "server-public-ip" {
  value = aws_eip.myapp_eip.public_ip
}

output "server-private-ip" {
  value = aws_instance.myapp-server.private_ip
}

# output "dev-subnet-id-2-default" {
#   value = aws_subnet.myapp-subnet-2.id
# }