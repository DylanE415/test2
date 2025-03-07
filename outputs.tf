// Outputs for the Terraform deployment

// Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

// Output the public subnets IDs
output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

// Output the private subnets IDs
output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

// Output the Load Balancer DNS name
output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.web_alb.dns_name
}

// Output the RDS endpoint
output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.prod.endpoint
}
