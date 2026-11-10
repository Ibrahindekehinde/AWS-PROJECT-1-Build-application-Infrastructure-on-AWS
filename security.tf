# 1. Load Balancer Security Group
resource "aws_security_group" "utc_alb_sg" {
  name        = "utc-alb-sg"
  description = "Allow HTTP traffic from the internet"
  vpc_id      = aws_vpc.sch-vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "utc-alb-sg"
  }
}


# 2. EC2 Application Security Group
resource "aws_security_group" "utc_ec2_sg" {
  name        = "utc-ec2-sg"
  description = "Allow HTTP traffic from load balancer"
  vpc_id      = aws_vpc.sch-vpc.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.utc_alb_sg.id]
  }

  # Allow SSH from Bastion Host
  ingress {
    description     = "Allow SSH from Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "utc-ec2-sg"
  }
}


# 3. RDS Database Security Group
resource "aws_security_group" "utc_rds_sg" {
  name        = "utc-rds-sg"
  description = "Allow MySQL access from EC2 servers"
  vpc_id      = aws_vpc.sch-vpc.id

  ingress {
    description     = "Allow MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.utc_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "utc-rds-sg"
  }
}


# 4. EFS Storage Security Group
resource "aws_security_group" "utc_efs_sg" {
  name        = "utc-efs-sg"
  description = "Allow NFS access from EC2 servers"
  vpc_id      = aws_vpc.sch-vpc.id

  ingress {
    description     = "Allow NFS from EC2"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.utc_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "utc-efs-sg"
  }
}



# Find the latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "utc-bastion-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.sch-vpc.id

  # SSH - Port 22
  ingress {
    description = "Allow SSH from my computer"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["151.231.95.129/32"]
  }

  # HTTP - Port 80
  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "utc-bastion-sg"
    env  = "dev"
    team = "config management"
  }
}

