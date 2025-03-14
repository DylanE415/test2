terraform {
  required_version = ">= 1.0"
}

// main.tf
// This file contains the resource definitions for the AWS RDS MySQL instance along with optional networking and security resources

// Optional: Create a DB Subnet Group for the RDS instance
resource "aws_db_subnet_group" "mydbsubnet" {
  name       = "${var.db_name}-subnet-group"
  description = "Subnet group for MySQL RDS instance deployment"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.db_name}-subnet-group"
  }
}

// Optional: Create a Security Group to control access to the RDS instance
resource "aws_security_group" "mydbsg" {
  name        = "${var.db_name}-sg"
  description = "Security group for MySQL RDS instance allowing MySQL access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_name}-sg"
  }
}// Create the AWS RDS MySQL DB instance
resource "aws_db_instance" "mysql" {
  identifier            = "${var.db_name}-instance"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  name                  = var.db_name
  username              = var.db_username
  password              = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.mydbsubnet.name
  vpc_security_group_ids = [aws_security_group.mydbsg.id]
  storage_encrypted     = true
  skip_final_snapshot   = true  // Skips final snapshot for non-production deployments

  tags = {    Name = "${var.db_name}-instance"
  }
}