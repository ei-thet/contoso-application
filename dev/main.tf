#Create a new VPC in AWS
resource "aws_vpc" "contoso_dev_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.environment}-vpc"
  }
}

#AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Security Group Resources
resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-alb-security-group"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.contoso_dev_vpc.id
  ingress {
    description = "HTTP from Internet"
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
    Name = "${var.environment}-alb-security-group"
  }
}

resource "aws_security_group" "asg_security_group" {
  name        = "${var.environment}-asg-security-group"
  description = "ASG Security Group"
  vpc_id      = aws_vpc.contoso_dev_vpc.id
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-asg-security-group"
  }
}

/*Internet Gateway: a network device that allows traffic to flow between your VPC and the internet. 
It is a fundamental component of any VPC network.*/
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.contoso_dev_vpc.id
  tags = {
    Name = "Terraform2023_internet_gateway"
  }
}