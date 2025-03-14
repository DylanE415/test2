// variables.tf
// This file defines all the variables used in the configuration

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "db_allocated_storage" {
  description = "The allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t2.micro"
}

variable "db_name" {
  description = "The name of the MySQL database"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The username for the MySQL database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the MySQL database"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID for the DB subnet group and security group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access the DB instance"
  type        = string
  default     = "0.0.0.0/0"
}