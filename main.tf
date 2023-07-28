resource "aws_instance" "jenkins_server" {
  ami                    = var.ami
  instance_type          = var.instance
  user_data              = file("jenkins.sh")
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = aws_subnet.tools_pub_sub.id
  associate_public_ip_address = true
  count = 1
  key_name = aws_key_pair.generated_key.key_name


  tags = {
    Name = "TF-Jenkins-Server${count.index + 1}"
  }
}

resource "tls_private_key" "rsa-key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name = var.key_name
  public_key = tls_private_key.rsa-key.public_key_openssh
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH and HTTP Traffic"
  vpc_id      = aws_vpc.tools_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "jenkins-sg"
  }
}

resource "aws_s3_bucket" "jenkins_artifacts001" {
  bucket = "jenkins-artifacts001"
}

resource "aws_vpc" "tools_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Tools-VPC"
  }
}

resource "aws_subnet" "tools_pub_sub" {
  vpc_id            = aws_vpc.tools_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Tools-Pub-Sub-1"
  }
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.tools_vpc.id
  
  tags = {
    Name = "tools_vpc_igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tools_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }
  tags = {
    Name = "tools_vpc_public_rt"
  }
}

resource "aws_route_table_association" "rt_sub_association" {
  subnet_id      = aws_subnet.tools_pub_sub.id
  route_table_id = aws_route_table.public_rt.id
}

output "private_key" {
  value = tls_private_key.rsa-key.private_key_pem
  sensitive = true
}