

variable "key_pair"                 {}
variable "VM-AMI"                   {}

// VPC110
variable "Subnet10_VPC110_id"       {}
variable "Subnet10_VPC110_base"     {}
variable "Subnet20_VPC110_id"       {}
variable "Subnet20_VPC110_base"     {}
variable "SG_VPC110"                {}

// VPC110
variable "Subnet10_VPC120_id"       {}
variable "Subnet10_VPC120_base"     {}
variable "Subnet20_VPC120_id"       {}
variable "Subnet20_VPC120_base"     {}
variable "SG_VPC120"                {}


/*==============================
EC2 Instances in 110-120 each AZ
===============================*/
resource "aws_network_interface" "VM1-Eth0" {
  subnet_id                     = var.Subnet10_VPC110_id
  security_groups               = [var.SG_VPC110]
  private_ips                   = [cidrhost(var.Subnet10_VPC110_base, 100)]
}
resource "aws_instance" "VM1" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM1-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair

  tags = {
    Name = "GC_VM1_VPC110"
  }
}

resource "aws_network_interface" "VM2-Eth0" {
  subnet_id                     = var.Subnet20_VPC110_id
  security_groups               = [var.SG_VPC110]
  private_ips                   = [cidrhost(var.Subnet20_VPC110_base, 100)]
}
resource "aws_instance" "VM2" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM2-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair

  tags = {
    Name = "GC_VM2_VPC110"
  }
}
resource "aws_network_interface" "VM3-Eth0" {
  subnet_id                     = var.Subnet10_VPC120_id
  security_groups               = [var.SG_VPC120]
  private_ips                   = [cidrhost(var.Subnet10_VPC120_base, 100)]
}
resource "aws_instance" "VM3" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM3-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair

  tags = {
    Name = "GC_VM3_VPC120"
  }
}

resource "aws_network_interface" "VM4-Eth0" {
  subnet_id                     = var.Subnet20_VPC120_id
  security_groups               = [var.SG_VPC120]
  private_ips                   = [cidrhost(var.Subnet20_VPC120_base, 100)]
}
resource "aws_instance" "VM4" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM4-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair

  tags = {
    Name = "GC_VM4_VPC120"
  }
}
/*================
Outputs variables for other modules to use
=================*/


