terraform {
  required_version = ">= 1.0"
}

// Main Terraform configuration file defining resources

//-------------------------
// VPC Configuration //-------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "production-vpc"
  }
}

//-------------------------
// Subnets Configuration//-------------------------
// Create public subnets for the load balancer
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

// Create private subnets for EC2 instances and RDS
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {    Name = "private-subnet-${count.index + 1}"
  }
}

//-------------------------
// Security Groups
//-------------------------
// Security group for web servers (EC2 instances)
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and HTTPS traffic to EC2 instances"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

// Security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow traffic only from the web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "MySQL access from web servers"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.web_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

//-------------------------
// RDS Instance
//-------------------------
resource "aws_db_instance" "prod" {
  identifier              = "production-db"
  allocated_storage       = var.db_allocated_storage
  engine                  = var.db_engine
  instance_class          = var.db_instance_class
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.prod.name
  skip_final_snapshot     = true

  tags = {
    Name = "production-db"
  }
}

// Define a DB subnet group for RDS to use the private subnets
resource "aws_db_subnet_group" "prod" {
  name       = "production-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name = "production-db-subnet-group"
  }
}

//-------------------------
// EC2 Launch Template
//-------------------------
resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-server-"
  image_id      = var.launch_template_ami
  instance_type = var.launch_template_instance_type
  key_name      = var.launch_template_key_name

  // Associate the web security group
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  // Example block device mapping (optional customization)
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
    }
  }

  // User data can be added here if needed
  # user_data = file("init-script.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server-instance"
    }
  }
}

//-------------------------
// Auto Scaling Group
//-------------------------

resource "aws_autoscaling_group" "web_asg" {
  name                      = "web-asg"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 3
  health_check_type         = "EC2"
  health_check_grace_period = 300
  // Use the launch template defined above
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  // Deploy EC2 instances in private subnets
  vpc_zone_identifier = aws_subnet.private[*].id

  // Attach the auto scaling group to the target group
  target_group_arns = [aws_lb_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }

  // Ensure ASG depends on the launch template
  depends_on = [aws_launch_template.web_lt]
}

//-------------------------
// Load Balancer and Listener
//-------------------------

// Application Load Balancer in public subnets
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "web-alb"
  }
}

// Target Group for the load balancer
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }

  tags = {
    Name = "web-tg"
  }
}

// Listener for the load balancer to forward traffic to target group
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}