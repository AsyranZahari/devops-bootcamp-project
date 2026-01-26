# EN: Public Route Table to allow internet access via Internet Gateway
# JP: インターネットゲートウェイ経由のアクセスを許可するパブリックルートテーブル
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-route-table" }
}

# EN: Associate Public Subnet with Public Route Table
# JP: パブリックサブネットをパブリックルートテーブルに関連付け
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# EN: Security Group for Web Server (Allows HTTP and SSH)
# JP: ウェブサーバー用セキュリティグループ（HTTPとSSHを許可）
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  vpc_id      = aws_vpc.main.id

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access (For configuration)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "public-security-group" }
}

# EN: Security Group for Private Servers (Ansible & Monitoring)
# JP: プライベートサーバー用セキュリティグループ（Ansibleとモニタリング）
resource "aws_security_group" "private_sg" {
  name        = "private-server-sg"
  vpc_id      = aws_vpc.main.id

  # Allow internal traffic from Web Server (For Prometheus monitoring)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "private-security-group" }
}