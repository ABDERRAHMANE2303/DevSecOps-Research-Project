#############################################
# Launch Template for EC2 App Instances
#############################################

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-app-"
  image_id      = data.aws_ami.al2.id
  instance_type = "t2.micro"               # Free-tier 
  key_name      = var.instances_key_name             # key for app instances (SSH from bastion)

  iam_instance_profile {
    name = "LabInstanceProfile"            # Use the pre-created LabInstanceProfile in the lab
  }

  network_interfaces {
    associate_public_ip_address = false     # private only
    security_groups             = [aws_security_group.app.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -euo pipefail
              yum update -y
              amazon-linux-extras install docker -y || yum install -y docker
              yum install -y awscli
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user

              REGION=${var.region}
              REPO=${aws_ecr_repository.app.repository_url}

              aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REPO"
              docker pull "$REPO:latest"
              docker run -d --name app --restart=always -p 80:8080 "$REPO:latest"
              EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30        
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-app-instance"
    })
  }
}

#############################################
# Auto Scaling Group
#############################################

resource "aws_autoscaling_group" "app" {
  name                      = "${local.name_prefix}-asg"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # vpc_zone_identifier       = [aws_subnet.private[0].id, aws_subnet.private[1].id] # 2 AZs only
  vpc_zone_identifier = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].id]  #for future maybe

  health_check_type         = "ELB"
  health_check_grace_period = 300

  target_group_arns         = [aws_lb_target_group.app.arn] 
  
  force_delete              = true
  wait_for_capacity_timeout = "10m"

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-asg-instance"
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.http]
}

#############################################
# CPU-based Scaling Policy
#############################################

resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "${local.name_prefix}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70  # Scale out when avg CPU > 70%
  alarm_actions       = [aws_autoscaling_policy.cpu_scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

resource "aws_autoscaling_policy" "cpu_scale_down" {
  name                   = "${local.name_prefix}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${local.name_prefix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30  # Scale in when avg CPU < 30%
  alarm_actions       = [aws_autoscaling_policy.cpu_scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}
