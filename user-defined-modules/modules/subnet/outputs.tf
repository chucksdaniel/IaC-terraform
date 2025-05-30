/*
  Way of exporting child module to be able to access it from parent module
*/

output "subnet" {
 value = aws_subnet.myapp-subnet-1
}
  