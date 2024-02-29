# Define the Terraform settings block
terraform {
  # Specify the required providers for this Terraform configuration
  required_providers {
    # Define the ACI provider with its source and version
    # The ACI provider is used to interact with Cisco's Application Centric Infrastructure
    aci = {
      source  = "ciscodevnet/aci"
      version = "2.13.2"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.0"
    } 
  }
  
  # Define the required Terraform version for this configuration
  required_version = "~> 1.7.2"
  
  # Configure the backend for storing Terraform state in an S3 bucket
  backend "s3" {
    bucket = "us-east1-tpatch-terraform" # Name of the S3 bucket
    key    = "root/workspaces/github/terraform.tfstate" # Path to the state file
    region = "us-east-1" # AWS region
  }      
}

provider "random" {

}

# Configure the ACI provider
provider "aci" {
  # Username for ACI authentication
  username = var.CISCO_ACI_TERRAFORM_USERNAME
  # Password for ACI authentication
  password = var.CISCO_ACI_TERRAFORM_PASSWORD
  # The URL for the ACI APIC endpoint
  url      = var.CISCO_ACI_APIC_IP_ADDRESS
  # Disable SSL verification for development or testing
  insecure = true
}

# Declare variables for ACI configuration
# Username variable
variable "CISCO_ACI_TERRAFORM_USERNAME" {
  type        = string
  description = "MAPS TO ENVIRONMENTAL VARIABLE TF_VAR_CISCO_ACI_TERRAFORM_USERNAME"
}

# Password variable, marked as sensitive
variable "CISCO_ACI_TERRAFORM_PASSWORD" {
  type        = string
  description = "MAPS TO ENVIRONMENTAL VARIABLE TF_VAR_CISCO_ACI_TERRAFORM_PASSWORD"
  sensitive   = true
}

# APIC IP address variable
variable "CISCO_ACI_APIC_IP_ADDRESS" {
  type        = string
  description = "MAPS TO ENVIRONMENTAL VARIABLE TF_VAR_CISCO_ACI_APIC_IP_ADDRESS"
}
