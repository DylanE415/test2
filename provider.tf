terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

// Provider configuration for AWS
// This file configures the AWS provider with the specified region and provides a placeholder for credentials

provider "aws" {
  region     = var.region
  # The variable var.project_id can be used to tag or reference your AWS project, if needed
  // credentials = file(var.credentials_file)

  // Optionally, you can add any provider-specific configuration here
}