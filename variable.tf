variable "access_key" {
}

variable "secret_key" {
}

variable "region" {
}

variable "cluster_name" {
  default = "terraform"
}

variable "default_egress_route" {
  default = "0.0.0.0/0"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zone1" {
  default = "cn-shanghai-f"
}

variable "availability_zone2" {
  default = "cn-shanghai-g"
}

variable "public_subnet_1" {
  default = "10.0.1.0/24"
}

variable "public_subnet_1_router" {
  default = "10.0.1.253"
}

variable "public_subnet_2" {
  default = "10.0.11.0/24"
}

variable "public_subnet_2_router" {
  default = "10.0.11.253"
}

variable "private_subnet_1" {
  default = "10.0.2.0/24"
}

variable "private_subnet_1_router" {
  default = "10.0.2.253"
}

variable "private_subnet_2" {
  default = "10.0.22.0/24"
}

variable "private_subnet_2_router" {
  default = "10.0.22.253"
}

variable "ha_subnet_1" {
  default = "10.0.3.0/24"
}

variable "ha_subnet_2" {
  default = "10.0.33.0/24"
}

variable "mgmt_subnet_1" {
  default = "10.0.4.0/24"
}

variable "mgmt_subnet_1_router" {
  default = "10.0.4.253"
}

variable "mgmt_subnet_2" {
  default = "10.0.44.0/24"
}

variable "mgmt_subnet_2_router" {
  default = "10.0.44.253"
}

variable "fgt1_protect_cidr" {
  default = "10.0.100.0/24"
}

variable "fgt2_protect_cidr" {
  default = "10.0.200.0/24"
}

variable "fgt1_port1_ip" {
  default = "10.0.1.100"
}

variable "fgt1_port2_ip" {
  default = "10.0.2.100"
}

variable "fgt1_port3_ip" {
  default = "10.0.3.100"
}

variable "fgt1_port4_ip" {
  default = "10.0.4.100"
}

variable "fgt2_port1_ip" {
  default = "10.0.11.100"
}

variable "fgt2_port2_ip" {
  default = "10.0.22.100"
}

variable "fgt2_port3_ip" {
  default = "10.0.33.100"
}

variable "fgt2_port4_ip" {
  default = "10.0.44.100"
}

variable "fgt1_byol_license" {
  description = "Provide the BYOL license filename for the first FortiGate instance, and place the file in the root module folder"
  default     = "fgt1-license.lic"
}

variable "fgt2_byol_license" {
  description = "Provide the BYOL license filename for the first FortiGate instance, and place the file in the root module folder"
  default     = "fgt2-license.lic"
}

variable "instance_type" {
  default = "ecs.c6.large"
}

