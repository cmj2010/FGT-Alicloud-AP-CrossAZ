# FGT-Alicloud-AP-CrossAZ

## Terrform deploy FortiGate native HA on Alicloud

- add access key and secert key in .tfvars  

- fill the license file content in fgt1-license.lic and fgt2-license.lic

1. terraform init

2. terraform plan

3. terraform apply

## Notice

- Note now Alicloud do not support interface index, interface attachment may not attach by order

- Alicoud do not support bind EIP to secondary eni by terraform