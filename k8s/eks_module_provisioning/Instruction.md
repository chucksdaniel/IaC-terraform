# Automating The Deployment Of EKS Cluster With Terraform on AWS
In this set up, We will utilize terreaform modules for the automation, You can click the [links](https://registry.terraform.io/modules/terraform-aws-modules) to learn more.

NOTE: Whenever you add new module, you need to run the command `terraform init` to download the modules


#### How to run terraform command with named profile
- `AWS_PROFILE=user_profile terraform plan` If you have multiple AWS users configured in ~/.aws/credentials, you can specify which profile to use by setting the `AWS_PROFILE` environment variable


We are using eks managed node group for deploying pods and containers

Assignment: Use self managed node group for EKS deployment

AWS_PROFILE=admin terraform plan