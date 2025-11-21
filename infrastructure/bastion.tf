############################################
# Bastion Host (public subnet, SSH jump)
############################################

# Reuse the AL2 AMI data source defined in application.tf
# data.aws_ami.al2.id

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public["0"].id        # first public subnet (AZ a)
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = var.bastion_key_name
  associate_public_ip_address = true

  # Optional: SSM, ECR, etc. via lab-provided instance profile
  iam_instance_profile = "LabInstanceProfile"

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    yum update -y
    yum install -y jq git htop mysql
  EOF

  root_block_device {
    volume_size           = 16
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion"
  })
}

# Profit from SSM to connect to bastion and VMs