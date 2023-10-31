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

#3Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.contoso_dev_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-public-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}

#3Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.contoso_dev_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-private-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}

/*Route table for public subnets, this ensures that all instances launched in 
public subnet will have access to the internet*/
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.contoso_dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${var.environment}-public-route-table"
  }
}


#Elastic IP 
/*An EIP is a public IP address that can be assigned to an instance or load balancer. EIPs can be used to 
make your instances accessible from the internet.*/
resource "aws_eip" "elastic_ip" {
  tags = {
    Name = "${var.environment}-elastic-ip"
  }
}

#AWS NAT Gateway:  
/*is a network device that allows instances in a private subnet to access the internet. 
It does this by translating the private IP addresses of the instances to public IP addresses.*/
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "Terraform2023InternetGateway"
  }
}

# Application Load Balancer Resources
/*Creates an Application Load Balancer (ALB) that is accessible from the internet, uses the application load balancer 
type, and uses the ALB security group. The ALB will be created in all public subnets.*/
resource "aws_lb" "alb" {
  depends_on         = [aws_autoscaling_group.auto_scaling_group]
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [for i in aws_subnet.public_subnet : i.id]
}

#creating a target group that listens on port 80 and uses the HTTP protocol. 
resource "aws_lb_target_group" "target_group" {
  name     = "${var.environment}-tgrp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.contoso_dev_vpc.id
  health_check {
    path    = "/"
    matcher = 200
  }
}

#Application Load Balancer: Is a powerful tool that can help you improve the performance, security, and 
#availability of your applications
/*Creating a listener that listens on port 80 and uses the HTTP protocol. The listener will be associated 
with the application load balancer*/
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  tags = {
    Name = "${var.environment}-alb-listenter"
  }
}