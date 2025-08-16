# main.tf

# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Or your preferred region
}

# --- IAM Roles ---
# 1. IAM Role for the EC2 instance to allow CodeDeploy to access it
resource "aws_iam_role" "ec2_role" {
  name = "EC2CodeDeployRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Attach the policy that allows the CodeDeploy agent to work
resource "aws_iam_role_policy_attachment" "ec2_codedeploy_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

# Create an instance profile to attach the role to the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2CodeDeployInstanceProfile"
  role = aws_iam_role.ec2_role.name
}

# --- Networking ---
# Security group to allow HTTP (port 80) and SSH (port 22) traffic
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For production, restrict this to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- EC2 Instance ---
# This is the server where Nginx will run
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups = [aws_security_group.web_sg.name]
  
  # User data script to install Nginx and the CodeDeploy agent on startup
  user_data = <<-EOF
              #!/bin/bash
              # Update packages
              yum update -y
              
              # Install Nginx
              amazon-linux-extras install nginx1 -y
              mkdir -p /var/www/pastel-notes
              systemctl start nginx
              systemctl enable nginx
              
              # Install CodeDeploy Agent
              yum install -y ruby wget
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              EOF

  tags = {
    Name = "Pastel-Notes-Server"
    # This tag is CRITICAL for CodeDeploy to identify the instance
    Deployment = "web-server" 
  }
}

# Output the public IP of the server
output "public_ip" {
  value = aws_instance.web_server.public_ip
}