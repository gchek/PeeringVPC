terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    nsxt = {
      source = "vmware/nsxt"
    }
  }
  required_version = ">= 0.13"
}
