# EN: Create an IAM Role for EC2 to use SSM
# JP: EC2がSSMを使用するためのIAMロールを作成する
resource "aws_iam_role" "ssm_role" {
  name = "devops-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# EN: Attach the standard SSM policy to the role
# JP: 標準のSSMポリシーをロールにアタッチする
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EN: Create an Instance Profile to be used by EC2
# JP: EC2で使用するインスタンスプロファイルを作成する
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "devops-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# EN: Add EC2 Instance Connect permission to the existing role
# JP: 既存のロールに EC2 Instance Connect の権限を追加する
resource "aws_iam_role_policy_attachment" "ec2_instance_connect_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceConnect" 
}