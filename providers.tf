
    terraform {
      required_providers {
        aci = {
          source = "ciscodevnet/aci"
          version = "2.13.2"
        }
      }
      
      required_version = "~> 1.7.2"
      
      backend "s3" {
        bucket = "us-east1-tpatch-terraform"
        key    = "root/workspaces/github/terraform.tfstate"
        region = "us-east-1"
      }      
    }
    
    provider "aci" {
      username = var.CISCO_ACI_TERRAFORM_USERNAME
      password = var.CISCO_ACI_TERRAFORM_PASSWORD
      url      = var.CISCO_ACI_APIC_IP_ADDRESS
      insecure = true
    }
    
    variable "CISCO_ACI_TERRAFORM_USERNAME" {
      type        = string
      description = "MAPS TO ENVIRONMENTAL VARIABLE TF_VAR_CISCO_ACI_TERRAFORM_USERNAME"
    }
    
    variable "CISCO_ACI_TERRAFORM_PASSWORD" {
      type        = string
      description = "MAPS TO ENVIRONMENTAL VARIABLE TF_VAR_CISCO_ACI_TERRAFORM_PASSWORD"
      sensitive   = true
    }
    
    variable "CISCO_ACI_APIC_IP_ADDRESS" {
      type        = string
      description = "MAPS TO ENVIRONMENTAL VARIABLE TF_VAR_CISCO_ACI_APIC_IP_ADDRESS"
    }
    