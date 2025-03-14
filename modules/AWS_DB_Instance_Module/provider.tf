// provider.tf
// This file configures the AWS provider for Terraform

provider "aws" {
  region  = var.region
  // For AWS, project_id is not directly used but provided as a placeholder: var.project_id

  // credentials = file(var.credentials_file)  // Uncomment and set the path to your AWS credentials file if needed
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}