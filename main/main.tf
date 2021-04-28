
terraform {
  backend "local" {
    path = "../../phase4.tfstate"
  }
}
//# Import the state from phase 2 and read the outputs
//data "terraform_remote_state" "phase2" {
//  backend = "local"
//  config = {
//    path    = "../../phase2.tfstate"
//  }
//}
provider "aws" {
  region    = var.AWS_region
}

provider "nsxt" {
  host                  = var.host
  vmc_token             = var.vmc_token
  allow_unverified_ssl  = true
  enforcement_point     = "vmc-enforcementpoint"
}
/*================
Create TGW
=================*/
module "TGW" {
  source = "../TGW"

  AWS_ASN_TGW           = var.AWS_ASN_TGW

  VPC110_cidr           = var.VPC110_cidr
  VPC110_id             = module.VPCs.VPC110_id
  Subnet110_10_id       = module.VPCs.Subnet10_VPC110_id
  Subnet110_20_id       = module.VPCs.Subnet20_VPC110_id

  VPC120_cidr           = var.VPC120_cidr
  VPC120_id             = module.VPCs.VPC120_id
  Subnet120_10_id       = module.VPCs.Subnet10_VPC120_id
  Subnet120_20_id       = module.VPCs.Subnet20_VPC120_id

  PeeringVPC_cidr       = var.PeeringVPC_cidr
  PeeringVPC_id         = module.VPCs.PeeringVPC_id
  Subnet10_VPCpeer_id   = module.VPCs.Subnet10_VPCpeer_id
  Subnet20_VPCpeer_id   = module.VPCs.Subnet20_VPCpeer_id
}
/*================
Create VPCs
=================*/
module "VPCs" {
  source = "../VPCs"

  VPC110_cidr           = var.VPC110_cidr
  Subnet110_10          = var.Subnet110_10
  Subnet110_20          = var.Subnet110_20

  VPC120_cidr           = var.VPC120_cidr
  Subnet120_10          = var.Subnet120_10
  Subnet120_20          = var.Subnet120_20

  PeeringVPC_cidr       = var.PeeringVPC_cidr
  PeeringVPC_10         = var.PeeringVPC_10
  PeeringVPC_20         = var.PeeringVPC_20

  Customer_TGW_id       = module.TGW.TGW_id
}


/*================
Create EC2s
=================*/
module "EC2s" {
  source = "../EC2s"

  VM-AMI                = var.VM_AMI
  key_pair              = var.key_pair

  // VPC110
  Subnet10_VPC110_id    = module.VPCs.Subnet10_VPC110_id
  Subnet10_VPC110_base  = var.Subnet110_10
  Subnet20_VPC110_id    = module.VPCs.Subnet20_VPC110_id
  Subnet20_VPC110_base  = var.Subnet110_20
  SG_VPC110             = module.VPCs.SG_VPC110

  // VPC120
  Subnet10_VPC120_id    = module.VPCs.Subnet10_VPC120_id
  Subnet10_VPC120_base  = var.Subnet120_10
  Subnet20_VPC120_id    = module.VPCs.Subnet20_VPC120_id
  Subnet20_VPC120_base  = var.Subnet120_20
  SG_VPC120             = module.VPCs.SG_VPC120


}




