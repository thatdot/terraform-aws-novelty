# -----------------------------------------------------------------------------
# Variables for Basic Example
# -----------------------------------------------------------------------------
# These variables allow customization of the Novelty deployment.
# Copy terraform.tfvars.example to terraform.tfvars and customize.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# AWS Configuration
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

# -----------------------------------------------------------------------------
# Container Configuration
# -----------------------------------------------------------------------------

variable "container_image" {
  description = "Docker image to run in the ECS task. This is required and must be provided by the user (e.g., '<your-account-id>.dkr.ecr.<region>.amazonaws.com/thatdot/novelty:<tag>')."
  type        = string
}

# -----------------------------------------------------------------------------
# Novelty License Configuration
# -----------------------------------------------------------------------------

variable "license_key_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret that holds the Novelty license key. Create it outside Terraform so the key never enters Terraform variables or state."
  type        = string
}

variable "license_server_uri" {
  description = "Novelty license server URI."
  type        = string
  default     = "https://license.thatdot.com"
}
