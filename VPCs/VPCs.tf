

/*================
Create VPCs
Create subnets
Create route tables
create security groups
=================*/

variable "VPC110_cidr"      {}
variable "Subnet110_10"     {}
variable "Subnet110_20"     {}

variable "VPC120_cidr"      {}
variable "Subnet120_10"     {}
variable "Subnet120_20"     {}

variable "PeeringVPC_cidr"  {}
variable "PeeringVPC_10"    {}
variable "PeeringVPC_20"    {}

variable "Customer_TGW_id"  {}

/*================
VPCs
=================*/

resource "aws_vpc" "VPC110" {
  cidr_block            = var.VPC110_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "GC_VPC110"
  }
}

resource "aws_vpc" "VPC120" {
  cidr_block            = var.VPC120_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "GC_VPC120"
  }
}

resource "aws_vpc" "PeeringVPC" {
  cidr_block            = var.PeeringVPC_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "GC_PeeringVPC"
  }
}

/*=============================
Subnets in attached VPC
==============================*/
# Get Availability zones in the Region
data "aws_availability_zones" "AZ" {}

resource "aws_subnet" "Subnet10_VPC110" {
  vpc_id     = aws_vpc.VPC110.id
  cidr_block = var.Subnet110_10
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[0]
  tags = {
    Name = "GC_Subnet10_VPC110"
  }
}
resource "aws_subnet" "Subnet20_VPC110" {
  vpc_id     = aws_vpc.VPC110.id
  cidr_block = var.Subnet110_20
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[1]
  tags = {
    Name = "GC_Subnet20_VPC110"
  }
}
resource "aws_subnet" "Subnet10_VPC120" {
  vpc_id     = aws_vpc.VPC120.id
  cidr_block = var.Subnet120_10
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[0]
  tags = {
    Name = "GC_Subnet10_VPC120"
  }
}

resource "aws_subnet" "Subnet20_VPC120" {
  vpc_id     = aws_vpc.VPC120.id
  cidr_block = var.Subnet120_20
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[1]
  tags = {
    Name = "GC_Subnet20_VPC120"
  }
}

resource "aws_subnet" "Subnet10_VPCpeer" {
  vpc_id     = aws_vpc.PeeringVPC.id
  cidr_block = var.PeeringVPC_10
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.AZ.names[0]
  tags = {
    Name = "GC_Subnet10_VPCpeer"
  }
}

resource "aws_subnet" "Subnet20_VPCpeer" {
  vpc_id     = aws_vpc.PeeringVPC.id
  cidr_block = var.PeeringVPC_20
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.AZ.names[1]
  tags = {
    Name = "GC_Subnet20_VPCpeer"
  }
}

/*================
IGWs
=================*/
resource "aws_internet_gateway" "IGW_110" {
  vpc_id = aws_vpc.VPC110.id
  tags = {
    Name = "GC_IGW_110"
  }
}
/*========================
default route tables
=========================*/

resource "aws_default_route_table" "PeeringVPC_RT" {
  default_route_table_id = aws_vpc.PeeringVPC.default_route_table_id
  lifecycle {
    ignore_changes = [route] # ignore any manually or ENI added routes
  }
  route {
    cidr_block = "172.0.0.0/8"
    transit_gateway_id = var.Customer_TGW_id
  }
  tags = {
    Name = "GC_PeeringVPC_RT"
  }
}

resource "aws_default_route_table" "VPC110_RT" {
  default_route_table_id = aws_vpc.VPC110.default_route_table_id

  route {
    cidr_block = "10.0.0.0/12"
    transit_gateway_id = var.Customer_TGW_id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_110.id
  }
  tags = {
    Name = "GC_VPC110_RT"
  }
}
resource "aws_default_route_table" "VPC120_RT" {
  default_route_table_id = aws_vpc.VPC120.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.Customer_TGW_id
  }
  tags = {
    Name = "GC_VPC120_RT"
  }
}


/*================================
Route Table association for VPCs
=================================*/

resource "aws_route_table_association" "RT_VPC110_10_assoc" {
  subnet_id      = aws_subnet.Subnet10_VPC110.id
  route_table_id  = aws_default_route_table.VPC110_RT.id
}
resource "aws_route_table_association" "RT_VPC110_20_assoc" {
  subnet_id      = aws_subnet.Subnet20_VPC110.id
  route_table_id  = aws_default_route_table.VPC110_RT.id
}
resource "aws_route_table_association" "RT_VPC120_10_assoc" {
  subnet_id      = aws_subnet.Subnet10_VPC120.id
  route_table_id  = aws_default_route_table.VPC120_RT.id
}
resource "aws_route_table_association" "RT_VPC120_20_assoc" {
  subnet_id      = aws_subnet.Subnet20_VPC120.id
  route_table_id  = aws_default_route_table.VPC120_RT.id
}
resource "aws_route_table_association" "RT_VPCpeer_10_assoc" {
  subnet_id      = aws_subnet.Subnet10_VPCpeer.id
  route_table_id  = aws_default_route_table.PeeringVPC_RT.id
}
resource "aws_route_table_association" "RT_VPCpeer_20_assoc" {
  subnet_id      = aws_subnet.Subnet20_VPCpeer.id
  route_table_id  = aws_default_route_table.PeeringVPC_RT.id
}


/*================
Security Groups
=================*/

resource "aws_security_group" "SG_VPC110" {
  name    = "SG_VPC110"
  vpc_id  = aws_vpc.VPC110.id
  tags = {
    Name = "GC_SG_VPC110"
  }
  #SSH, all PING and others
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all PING"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow iPERF3"
    from_port = 5201
    to_port = 5201
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "SG_VPC120" {
  name    = "SG_VPC120"
  vpc_id  = aws_vpc.VPC120.id
  tags = {
    Name = "GC_SG_VPC110"
  }
  #SSH, all PING and others
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all PING"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow iPERF3"
    from_port = 5201
    to_port = 5201
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*===================================
  Outputs variables for other modules
====================================*/

output "VPC110_id"                {value = aws_vpc.VPC110.id}
output "Subnet10_VPC110_id"       {value = aws_subnet.Subnet10_VPC110.id}
output "Subnet20_VPC110_id"       {value = aws_subnet.Subnet20_VPC110.id}
output "SG_VPC110"                {value = aws_security_group.SG_VPC110.id}

output "VPC120_id"                {value = aws_vpc.VPC120.id}
output "Subnet10_VPC120_id"       {value = aws_subnet.Subnet10_VPC120.id}
output "Subnet20_VPC120_id"       {value = aws_subnet.Subnet20_VPC120.id}
output "SG_VPC120"                {value = aws_security_group.SG_VPC120.id}

output "PeeringVPC_id"            {value = aws_vpc.PeeringVPC.id}
output "Subnet10_VPCpeer_id"      {value = aws_subnet.Subnet10_VPCpeer.id}
output "Subnet20_VPCpeer_id"      {value = aws_subnet.Subnet20_VPCpeer.id}


