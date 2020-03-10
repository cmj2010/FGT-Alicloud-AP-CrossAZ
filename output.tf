output "fgt1_public_ip" {
  value = alicloud_eip.cluster_ip.ip_address
}
output "fgt1_instance_id" {
  value = alicloud_instance.fgt1.id
}