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

# EN: Allocate an Elastic IP for the NAT Gateway
# JP: NATゲートウェイ用のエラスティックIPを割り当てる
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "nat-gateway-eip" }
}

# EN: Create the NAT Gateway in the Public Subnet
# JP: パブリックサブネットにNATゲートウェイを作成する
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id # NAT mesti duduk di tempat ada internet

  tags = { Name = "main-nat-gateway" }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  depends_on = [aws_internet_gateway.igw]
}

# EN: Private Route Table to allow private servers to access internet via NAT
# JP: プライベートサーバーがNAT経由でインターネットにアクセスするためのルートテーブル
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = { Name = "private-route-table" }
}

# EN: Associate Private Subnet with Private Route Table
# JP: プライベートサブネットをプライベートルートテーブルに関連付け
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# EN: Open Access Port 3000 (Grafana)
# JP: Port 3000 アクセスポートを開く(Grafana)
resource "aws_security_group_rule" "allow_grafana" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Allow access from any IP
  security_group_id = aws_security_group.web_sg.id
}

# EN: Open Prometheus Web UI (Port 9090)
resource "aws_security_group_rule" "allow_prometheus_ui" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_security_group.web_sg.id
}

# EN: Open Node Exporter Port (Port 9100) - 
resource "aws_security_group_rule" "allow_node_exporter" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr] # Allow acces from inside VPC only
  security_group_id = aws_security_group.web_sg.id
}
