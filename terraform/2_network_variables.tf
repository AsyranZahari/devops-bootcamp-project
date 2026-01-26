# EN: Main VPC network address 
# JP: メインVPCネットワークアドレス 
variable "vpc_cidr" {
  default = "10.0.0.0/24"
}

# EN: Public Subnet address for Web Server 
# JP: ウェブサーバー用のパブリックサブネットアドレス 
variable "public_subnet_cidr" {
  default = "10.0.0.0/25"
}

# EN: Private Subnet address for Monitoring & Ansible 
# JP: モニタリングとAnsible用のプライベートサブネットアドレス 
variable "private_subnet_cidr" {
  default = "10.0.0.128/25"
}

# EN: Operating system image ID (Ubuntu 24.04) 
# JP: オペレーティングシステムのイメージID (Ubuntu 24.04) 
variable "ami_id" {
  default = "ami-01811d4912b4ccb26" 
}

# EN: EC2 instance hardware size 
# JP: EC2インスタンスのハードウェアサイズ 
variable "instance_type" {
  default = "t3.micro"
}