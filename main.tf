provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "random_string" "random_name_post" {
  length           = 3
  special          = true
  override_special = ""
  min_lower        = 3
}

resource "alicloud_vpc" "terraformvpc" {
  name       = "terraformvpc"
  cidr_block = var.vpc_cidr
}

resource "alicloud_vswitch" "public-vsw1" {
  vpc_id            = alicloud_vpc.terraformvpc.id
  cidr_block        = var.public_subnet_1
  availability_zone = var.availability_zone1
}

resource "alicloud_vswitch" "private-vsw1" {
  vpc_id            = alicloud_vpc.terraformvpc.id
  cidr_block        = var.private_subnet_1
  availability_zone = var.availability_zone1
}

resource "alicloud_vswitch" "terraform-ha1" {
  vpc_id            = alicloud_vpc.terraformvpc.id
  cidr_block        = var.ha_subnet_1
  availability_zone = var.availability_zone1
}

resource "alicloud_vswitch" "terraform-mgmt1" {
  vpc_id            = alicloud_vpc.terraformvpc.id
  cidr_block        = var.mgmt_subnet_1
  availability_zone = var.availability_zone1
}

resource "alicloud_vswitch" "public-vsw2" {
  vpc_id            = alicloud_vpc.terraformvpc.id
  cidr_block        = var.public_subnet_2
  availability_zone = var.availability_zone2
}

resource "alicloud_vswitch" "private-vsw2" {
  vpc_id            = alicloud_vpc.terraformvpc.id
  cidr_block        = var.private_subnet_2
  availability_zone = var.availability_zone2
}

resource "alicloud_vswitch" "terraform-ha2" {
  vpc_id            = alicloud_vpc.terraformvpc.id
  cidr_block        = var.ha_subnet_2
  availability_zone = var.availability_zone2
}

resource "alicloud_vswitch" "terraform-mgmt2" {
  vpc_id            = alicloud_vpc.terraformvpc.id
  cidr_block        = var.mgmt_subnet_2
  availability_zone = var.availability_zone2
}

resource "alicloud_ram_role" "ram_role" {
  name        = "FGT-HA-Role-${random_string.random_name_post.result}"
  document    = <<EOF
{
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
    "Principal": {
        "Service": [
            "ecs.aliyuncs.com"
        ]
    }
    }
],
"Version": "1"
}
EOF
  description = "this is a HA role."
  force       = true
}

resource "alicloud_ram_role_policy_attachment" "attach1" {
  policy_name = "AliyunECSFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.ram_role.name
}

resource "alicloud_ram_role_policy_attachment" "attach2" {
  policy_name = "AliyunVPCFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.ram_role.name
}

resource "alicloud_ram_role_policy_attachment" "attach3" {
  policy_name = "AliyunEIPFullAccess"
  policy_type = "System"
  role_name   = alicloud_ram_role.ram_role.name
}

resource "alicloud_security_group" "fgtsg" {
  name   = "fgtsg"
  vpc_id = alicloud_vpc.terraformvpc.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.fgtsg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "fgt1" {
  availability_zone    = var.availability_zone1
  security_groups      = alicloud_security_group.fgtsg.*.id
  instance_type        = var.instance_type
  system_disk_category = "cloud_efficiency"
  image_id             = lookup(var.fgt-byol-amis, var.region)
  instance_name        = "fgt1"
  role_name            = alicloud_ram_role.ram_role.name
  user_data            = data.template_file.fgt1_userdata.rendered
  vswitch_id           = alicloud_vswitch.public-vsw1.id
  private_ip           = var.fgt1_port1_ip
  depends_on           = [alicloud_ram_role.ram_role]
}
data "template_file" "fgt1_userdata" {
  template = "${file("${path.module}/fgt1-userdata.tpl")}"
  vars = {
    fgt1_id                 = "fgt-1"
    fgt1_byol_license       = file("${path.root}/${var.fgt1_byol_license}")
    public_subnet_1_router  = var.public_subnet_1_router
    private_subnet_1_router = var.private_subnet_1_router
    mgmt_subnet_1_router    = var.mgmt_subnet_1_router
    vpc_cidr                = var.vpc_cidr
    fgt1_port1_ip           = var.fgt1_port1_ip
    fgt1_port2_ip           = var.fgt1_port2_ip
    fgt1_port3_ip           = var.fgt1_port3_ip
    fgt1_port4_ip           = var.fgt1_port4_ip
    fgt2_port3_ip           = var.fgt2_port3_ip
  }
}

resource "alicloud_instance" "fgt2" {
  availability_zone    = var.availability_zone2
  security_groups      = alicloud_security_group.fgtsg.*.id
  instance_type        = var.instance_type
  system_disk_category = "cloud_efficiency"
  image_id             = lookup(var.fgt-byol-amis, var.region)
  instance_name        = "fgt2"
  role_name            = alicloud_ram_role.ram_role.name
  user_data            = data.template_file.fgt2_userdata.rendered
  vswitch_id           = alicloud_vswitch.public-vsw2.id
  private_ip           = var.fgt2_port1_ip
  depends_on           = [alicloud_ram_role.ram_role]
}
data "template_file" "fgt2_userdata" {
  template = "${file("${path.module}/fgt2-userdata.tpl")}"
  vars = {
    fgt2_id                 = "fgt-2"
    fgt2_byol_license       = file("${path.root}/${var.fgt2_byol_license}")
    public_subnet_2_router  = var.public_subnet_2_router
    private_subnet_2_router = var.private_subnet_2_router
    mgmt_subnet_2_router    = var.mgmt_subnet_2_router
    vpc_cidr                = var.vpc_cidr
    fgt2_port1_ip           = var.fgt2_port1_ip
    fgt2_port2_ip           = var.fgt2_port2_ip
    fgt2_port3_ip           = var.fgt2_port3_ip
    fgt2_port4_ip           = var.fgt2_port4_ip
    fgt1_port3_ip           = var.fgt1_port3_ip
  }
}

resource "alicloud_network_interface" "fgt1_port2" {
  name            = "fgt1_port2"
  vswitch_id      = alicloud_vswitch.private-vsw1.id
  private_ip      = var.fgt1_port2_ip
  security_groups = alicloud_security_group.fgtsg.*.id
}

resource "alicloud_network_interface" "fgt1_port3" {
  name            = "fgt1_port3"
  vswitch_id      = alicloud_vswitch.terraform-ha1.id
  private_ip      = var.fgt1_port3_ip
  security_groups = alicloud_security_group.fgtsg.*.id
}

resource "alicloud_network_interface" "fgt1_port4" {
  name            = "fgt1_port4"
  vswitch_id      = alicloud_vswitch.terraform-mgmt1.id
  private_ip      = var.fgt1_port4_ip
  security_groups = alicloud_security_group.fgtsg.*.id
}

resource "alicloud_network_interface" "fgt2_port2" {
  name            = "fgt2_port2"
  vswitch_id      = alicloud_vswitch.private-vsw2.id
  private_ip      = var.fgt2_port2_ip
  security_groups = alicloud_security_group.fgtsg.*.id
}

resource "alicloud_network_interface" "fgt2_port3" {
  name            = "fgt2_port3"
  vswitch_id      = alicloud_vswitch.terraform-ha2.id
  private_ip      = var.fgt2_port3_ip
  security_groups = alicloud_security_group.fgtsg.*.id
}

resource "alicloud_network_interface" "fgt2_port4" {
  name            = "fgt2_port4"
  vswitch_id      = alicloud_vswitch.terraform-mgmt2.id
  private_ip      = var.fgt2_port4_ip
  security_groups = alicloud_security_group.fgtsg.*.id
}

resource "alicloud_network_interface_attachment" "attachment-fgt1port2" {
  instance_id          = alicloud_instance.fgt1.id
  network_interface_id = alicloud_network_interface.fgt1_port2.id
  depends_on           = [alicloud_instance.fgt1]
}

resource "alicloud_network_interface_attachment" "attachment-fgt1port3" {
  instance_id          = alicloud_instance.fgt1.id
  network_interface_id = alicloud_network_interface.fgt1_port3.id
  depends_on           = [alicloud_instance.fgt1, alicloud_network_interface_attachment.attachment-fgt1port2]
}

resource "alicloud_network_interface_attachment" "attachment-fgt1port4" {
  instance_id          = alicloud_instance.fgt1.id
  network_interface_id = alicloud_network_interface.fgt1_port4.id
  depends_on           = [alicloud_instance.fgt1, alicloud_network_interface_attachment.attachment-fgt1port3]
}

resource "alicloud_network_interface_attachment" "attachment-fgt2port2" {
  instance_id          = alicloud_instance.fgt2.id
  network_interface_id = alicloud_network_interface.fgt2_port2.id
  depends_on           = [alicloud_instance.fgt2]
}

resource "alicloud_network_interface_attachment" "attachment-fgt2port3" {
  instance_id          = alicloud_instance.fgt2.id
  network_interface_id = alicloud_network_interface.fgt2_port3.id
  depends_on           = [alicloud_instance.fgt2, alicloud_network_interface_attachment.attachment-fgt2port2]
}

resource "alicloud_network_interface_attachment" "attachment-fgt2port4" {
  instance_id          = alicloud_instance.fgt2.id
  network_interface_id = alicloud_network_interface.fgt2_port4.id
  depends_on           = [alicloud_instance.fgt2, alicloud_network_interface_attachment.attachment-fgt2port3]
}

resource "alicloud_route_table" "private_route_table" {
  vpc_id      = alicloud_vpc.terraformvpc.id
  name        = "privatert"
  description = "FortiGate Egress route table, created with terraform."
}

resource "alicloud_route_entry" "custom_route_table_egress" {
  route_table_id        = alicloud_route_table.private_route_table.id
  destination_cidrblock = var.default_egress_route
  nexthop_type          = "NetworkInterface"
  nexthop_id            = alicloud_network_interface.fgt1_port2.id
  name                  = alicloud_network_interface.fgt1_port2.id
  depends_on            = [alicloud_instance.fgt1, alicloud_network_interface.fgt1_port2]
}

resource "alicloud_route_table_attachment" "private_route_table_attachment1" {
  vswitch_id     = alicloud_vswitch.private-vsw1.id
  route_table_id = alicloud_route_table.private_route_table.id
  depends_on     = [alicloud_instance.fgt1, alicloud_vswitch.private-vsw1]
}

resource "alicloud_route_table_attachment" "private_route_table_attachment2" {
  vswitch_id     = alicloud_vswitch.private-vsw2.id
  route_table_id = alicloud_route_table.private_route_table.id
  depends_on     = [alicloud_instance.fgt1, alicloud_vswitch.private-vsw2]
}

resource "alicloud_eip" "cluster_ip" {
  bandwidth            = "10"
  internet_charge_type = "PayByBandwidth"
}

resource "alicloud_eip" "fgt1_mgmt_ip" {
  bandwidth            = "10"
  internet_charge_type = "PayByBandwidth"
}

resource "alicloud_eip" "fgt2_mgmt_ip" {
  bandwidth            = "10"
  internet_charge_type = "PayByBandwidth"
}

resource "alicloud_eip_association" "cluster_ip" {
  allocation_id = alicloud_eip.cluster_ip.id
  instance_id   = alicloud_instance.fgt1.id
  depends_on    = [alicloud_instance.fgt1]
}