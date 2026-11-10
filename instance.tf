# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# Application Server in Private Subnet 1A
resource "aws_instance" "appserver_1a" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private_app_1.id
  vpc_security_group_ids = [aws_security_group.utc_ec2_sg.id]
  key_name               = aws_key_pair.utc1key.key_name

  associate_public_ip_address = false

  user_data = file("file.sh")

  tags = {
    Name = "appserver-1a"
    env  = "dev"
    team = "config management"
  }

  depends_on = [
  aws_route_table_association.private_app_1,
  aws_route_table_association.private_app_3
  ] 
}



# Application Server in Private Subnet 1B
resource "aws_instance" "appserver_1b" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private_app_2.id
  vpc_security_group_ids = [aws_security_group.utc_ec2_sg.id]
  key_name               = aws_key_pair.utc1key.key_name

  associate_public_ip_address = false

  user_data = file("file.sh")

  tags = {
    Name = "appserver-1b"
    env  = "dev"
    team = "config management"
  }

  depends_on = [
  aws_route_table_association.private_app_2
  ]
}

# Bastion Host EC2 Instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.amazon_linux.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.utc1key.key_name

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  tags = {
    Name = "utc-bastion-host"
    env  = "dev"
    team = "config management"
  }
}
