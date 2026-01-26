# EN: Creating a Virtual Private Cloud (VPC) 
# JP: 仮想プライベートクラウド (VPC) の作成 
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "devops-vpc" }
}

# EN: Creating an Internet Gateway for public access
# JP: 公開アクセスのためのインターネットゲートウェイの作成 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "devops-igw" }
}

# EN: Creating a Public Subnet
# JP: パブリックサブネットの作成 
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  tags = { Name = "devops-public-subnet" }
}

# EN: Creating a Private Subnet 
# JP: プライベートサブネットの作成 
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
  tags = { Name = "devops-private-subnet" }
}

# EN: Creating the Web Server (Public) 
# JP: ウェブサーバー（パブリック）の作成 
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  private_ip    = "10.0.0.5" 
  tags = { Name = "Web-Server" }
  vpc_security_group_ids = [aws_security_group.web_sg.id] # Added security group id
}

# EN: Creating the Ansible Controller (Private) 
# JP: Ansibleコントローラー（プライベート）の作成 
resource "aws_instance" "ansible_controller" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  private_ip    = "10.0.0.135" 
  tags = { Name = "Ansible-Server" }
  vpc_security_group_ids = [aws_security_group.web_sg.id] # Added security group id
}

# EN: Creating the Monitoring Server (Private) 
# JP: モニタリングサーバー（プライベート）の作成 
resource "aws_instance" "monitoring_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  private_ip    = "10.0.0.136" 
  tags = { Name = "Monitoring-Server" }
  vpc_security_group_ids = [aws_security_group.web_sg.id] # Added security group id
}