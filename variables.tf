// Variable definitions for the Terraform configuration

// AWS region for resource deployment
variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

// VPC configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

// Public subnets for load balancer
variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

// Private subnets for EC2 instances and RDS
variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

// Availability zones for subnet distribution
variable "availability_zones" {
  description = "List of availability zones to be used for resource deployment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

// RDS configuration variables
variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes for the RDS instance"
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "Database engine for RDS"
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "The instance type for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The database name"
  type        = string
  default     = "productiondb"
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
}

// Launch Template configuration variables
variable "launch_template_ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" // example AMI; change as needed
}

variable "launch_template_instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "launch_template_key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = "default-key"
}