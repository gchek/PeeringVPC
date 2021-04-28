variable "vmc_token"        {}
variable "host"             {}
variable "AWS_region"       {default = "us-west-2"}
variable "key_pair"         {default = "my-oregon-key" }
variable "VM_AMI"           { default = "ami-0528a5175983e7f28" } # Amazon Linux 2 AMI (HVM), SSD Volume Type - Oregon


/*================
VPCs data
=================*/

variable "AWS_ASN_TGW"      {default = 64512}

variable "VPC110_cidr"      {default = "172.110.0.0/16"}
variable "Subnet110_10"     {default = "172.110.10.0/24"}
variable "Subnet110_20"     {default = "172.110.20.0/24"}

variable "VPC120_cidr"      {default = "172.120.0.0/16"}
variable "Subnet120_10"     {default = "172.120.10.0/24"}
variable "Subnet120_20"     {default = "172.120.20.0/24"}

variable "PeeringVPC_cidr"  {default = "172.0.0.0/16"}
variable "PeeringVPC_10"    {default = "172.0.10.0/24"}
variable "PeeringVPC_20"    {default = "172.0.20.0/24"}



