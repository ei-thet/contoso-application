
#outputs.tf
/*This code defines an output called alb_public_url with the description "Public URL for Application Load Balancer" 
and the value of the DNS name of the Application Load Balancer. This output can be used to get the public URL of the 
Application Load Balancer after Terraform has been applied. */
# Terraform Outputs
output "alb_public_url" {
  description = "Public URL for Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "availability_zone" {
  description = "Public URL for Application Load Balancer"
  value       = data.aws_availability_zones.available.names
}

# Launch Template Outputs
# output "launch_template_id" {
#   description = "Launch Template ID"
#   value = aws_launch_template.launch_template_meow.id
# }

# output "launch_template_latest_version" {
#   description = "Launch Template Latest Version"
#   value = aws_launch_template.launch_template_meow_new.latest_version
# }