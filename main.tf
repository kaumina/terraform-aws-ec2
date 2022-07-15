# Terraform AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.75"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region

}

# Pull the latest Amazon Linux AMI

data "aws_ami" "amazon-linux-2" {

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

}

# Pull SSM managed policy for session manager 
data "aws_iam_policy" "SSMSessionRolePolicy" {
  name = "AmazonSSMManagedInstanceCore"
}

# Create session role resource
resource "aws_iam_role" "SSMSessionRole" {
  name                = "ssh-SessionManagerRole"
  managed_policy_arns = ["${data.aws_iam_policy.SSMSessionRolePolicy.arn}"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "SSMAccessRole"
  }

  # Create the Instance Profile
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.SSMSessionRole.name
}

# Create the security group to allow port 80
resource "aws_security_group" "allow_80" {
  name        = "allow_port_80"
  description = "Allow port 80 inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_80"
  }
}

# Create the EC2 resource

resource "aws_instance" "amazon-linux" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = var.instance-type
  associate_public_ip_address = true
  user_data                   = file("${path.module}/files/user-data.sh")
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.id
  security_groups             = ["${aws_security_group.allow_80.name}"]


  tags = {
    Name = "HelloWorld"
  }


}