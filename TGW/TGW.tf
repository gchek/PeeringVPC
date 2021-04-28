
variable "AWS_ASN_TGW"          {}

variable "VPC110_cidr"          {}
variable "VPC110_id"            {}
variable "Subnet110_10_id"      {}
variable "Subnet110_20_id"      {}

variable "VPC120_cidr"          {}
variable "VPC120_id"            {}
variable "Subnet120_10_id"      {}
variable "Subnet120_20_id"      {}

variable "PeeringVPC_cidr"      {}
variable "PeeringVPC_id"        {}
variable "Subnet10_VPCpeer_id"  {}
variable "Subnet20_VPCpeer_id"  {}



/*===========================================
Create TGW
============================================*/

resource "aws_ec2_transit_gateway" "Customer_TGW" {
  description     = "Customer_TGW"
  amazon_side_asn = var.AWS_ASN_TGW
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "GC_Customer_TGW"
  }
}
//resource "aws_ec2_transit_gateway_route_table" "Default_TGW_RT" {
//  transit_gateway_id = aws_ec2_transit_gateway.Customer_TGW.id
//  tags = {
//    Name = "GC_Defaut_TGW_RT"
//  }
//}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC110_attachment" {
  subnet_ids          = [var.Subnet110_10_id, var.Subnet110_20_id]
  transit_gateway_id  = aws_ec2_transit_gateway.Customer_TGW.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id              = var.VPC110_id
  tags = {
    Name = "GC_VPC110_attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC120_attachment" {
  subnet_ids          = [var.Subnet120_10_id, var.Subnet120_20_id]
  transit_gateway_id  = aws_ec2_transit_gateway.Customer_TGW.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id              = var.VPC120_id
  tags = {
    Name = "GC_VPC120_attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "PeeringVPC_AWS_attachment" {
  subnet_ids          = [var.Subnet10_VPCpeer_id, var.Subnet20_VPCpeer_id]
  transit_gateway_id  = aws_ec2_transit_gateway.Customer_TGW.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id              = var.PeeringVPC_id
  tags = {
    Name = "GC_PeeringVPC_AWS_side"
  }
}

/*=============================================
TGW Route table Associations and Propagations
==============================================*/
resource "aws_ec2_transit_gateway_route_table" "Main_TGW_RT" {
  transit_gateway_id = aws_ec2_transit_gateway.Customer_TGW.id
  tags = {
    Name = "GC_Main_TGW_RT"
  }
}
// Associations
resource "aws_ec2_transit_gateway_route_table_association" "VPC110_assoc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.VPC110_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Main_TGW_RT.id
}
resource "aws_ec2_transit_gateway_route_table_association" "VPC120_assoc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.VPC120_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Main_TGW_RT.id
}
resource "aws_ec2_transit_gateway_route_table_association" "PeeringVPC_AWS_assoc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.PeeringVPC_AWS_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Main_TGW_RT.id
}

// Progagations
resource "aws_ec2_transit_gateway_route_table_propagation" "VPC110_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.VPC110_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Main_TGW_RT.id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "VPC120_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.VPC120_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Main_TGW_RT.id
}
/*=============================================
Add static route pointing to Peering VPC
==============================================*/
resource "aws_ec2_transit_gateway_route" "static_0_0" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.PeeringVPC_AWS_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Main_TGW_RT.id
}


/*================
Outputs variables
=================*/

output "TGW_id"         { value = aws_ec2_transit_gateway.Customer_TGW.id}

