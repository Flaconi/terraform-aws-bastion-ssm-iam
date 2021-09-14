terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
  required_version = ">= 0.12.26"
}
