output "aws_ami_id" {
  value = module.myapp-server.myapp_instance
}

output "server-public-ip" {
  value = module.myapp-server.myapp_instance.associate_public_ip_address
}
