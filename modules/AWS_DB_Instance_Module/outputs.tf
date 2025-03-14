// outputs.tf
// This file defines the outputs for the deployment

// Output the endpoint address of the MySQL RDS instance
output "db_endpoint" {
  description = "The endpoint address of the MySQL RDS instance"
  value       = aws_db_instance.mysql.address
}

// Output the identifier of the MySQL RDS instance
output "db_instance_identifier" {
  description = "The identifier for the MySQL RDS instance"
  value       = aws_db_instance.mysql.id
}
