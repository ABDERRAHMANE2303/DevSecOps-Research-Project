###################################################################
# Security Groups
# - ALB: 80/443 from world; simple egress for now
# - App: 80 from ALB; 22 from Bastion; egress 3306->DB, 443->internet
# - Bastion: 22 from admin CIDR; egress 22->App, 3306->DB, 443->internet
# - DB: 3306 from App (and Bastion); egress allow all
###################################################################

# ALB SG
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB ingress 80/443 from the world"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # can be enhanced 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-alb-sg" })
}

# App (EC2/ASG) SG
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "App instances"
  vpc_id      = aws_vpc.main.id

  # App port from ALB
  ingress {
    description     = "App port from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH from Bastion
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }


  # Egress to internet for updates (via NAT)
  egress {
    description = "HTTPS to internet for updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-app-sg" })
}

# Bastion SG
resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Bastion host"
  vpc_id      = aws_vpc.main.id

  # SSH only from admin CIDR
  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip + "/32"]
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-bastion-sg" })
}

# DB SG
resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "RDS MySQL"
  vpc_id      = aws_vpc.main.id

  # From App
  ingress {
    description     = "MySQL from app"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # from Bastion for admin
  ingress {
    description     = "MySQL from bastion (admin)"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Egress allow all 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-db-sg" })
}