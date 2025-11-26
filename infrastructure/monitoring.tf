# monitoring within lab limits
resource "aws_guardduty_detector" "main" {
	enable = true
}

# ALB - target 5xx
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
	alarm_name          = "${local.name_prefix}-alb-5xx"
	alarm_description   = "ALB target 5xx spike"
	namespace           = "AWS/ApplicationELB"
	metric_name         = "HTTPCode_Target_5XX_Count"
	statistic           = "Sum"
	period              = 300
	evaluation_periods  = 1
	threshold           = 10
	comparison_operator = "GreaterThanThreshold"
	dimensions = {
		LoadBalancer = aws_lb.app.arn_suffix
		TargetGroup  = aws_lb_target_group.app.arn_suffix
	}
}

# Target unhealthy hosts
resource "aws_cloudwatch_metric_alarm" "tg_unhealthy" {
	alarm_name          = "${local.name_prefix}-tg-unhealthy"
	alarm_description   = "Target group unhealthy hosts"
	namespace           = "AWS/ApplicationELB"
	metric_name         = "UnHealthyHostCount"
	statistic           = "Average"
	period              = 60
	evaluation_periods  = 2
	threshold           = 1
	comparison_operator = "GreaterThanThreshold"
	dimensions = {
		TargetGroup = aws_lb_target_group.app.arn_suffix
	}
}

# RDS CPU
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
	alarm_name          = "${local.name_prefix}-rds-cpu-high"
	alarm_description   = "RDS CPU high"
	namespace           = "AWS/RDS"
	metric_name         = "CPUUtilization"
	statistic           = "Average"
	period              = 300
	evaluation_periods  = 2
	threshold           = 70
	comparison_operator = "GreaterThanThreshold"
	dimensions = {
		DBInstanceIdentifier = aws_db_instance.app.identifier
	}
}

# ALB response time
resource "aws_cloudwatch_metric_alarm" "alb_latency" {
	alarm_name          = "${local.name_prefix}-alb-latency"
	alarm_description   = "ALB target response time high"
	namespace           = "AWS/ApplicationELB"
	metric_name         = "TargetResponseTime"
	statistic           = "Average"
	period              = 60
	evaluation_periods  = 3
	threshold           = 1.0
	comparison_operator = "GreaterThanThreshold"
	dimensions = {
		TargetGroup = aws_lb_target_group.app.arn_suffix
	}
}

# Dashboard
resource "aws_cloudwatch_dashboard" "overview" {
	dashboard_name = "${local.name_prefix}-overview"
	dashboard_body = <<DASH
{
	"widgets": [
		{"type": "metric", "x": 0, "y": 0, "width": 12, "height": 6,
		 "properties": {"metrics": [["AWS/ApplicationELB","HTTPCode_Target_5XX_Count","LoadBalancer","${aws_lb.app.arn_suffix}","TargetGroup","${aws_lb_target_group.app.arn_suffix}" ]],"period":300,"stat":"Sum","title":"ALB 5XX"}}
		,{"type":"metric","x":12,"y":0,"width":12,"height":6,
		 "properties": {"metrics": [["AWS/ApplicationELB","TargetResponseTime","TargetGroup","${aws_lb_target_group.app.arn_suffix}"]],"period":60,"stat":"Average","title":"ALB Response Time"}}
		,{"type":"metric","x":0,"y":6,"width":12,"height":6,
		 "properties": {"metrics": [["AWS/ApplicationELB","UnHealthyHostCount","TargetGroup","${aws_lb_target_group.app.arn_suffix}"]],"period":60,"stat":"Average","title":"Target Unhealthy Hosts"}}
		,{"type":"metric","x":12,"y":6,"width":12,"height":6,
		 "properties": {"metrics": [["AWS/RDS","CPUUtilization","DBInstanceIdentifier","${aws_db_instance.app.identifier}"]],"period":300,"stat":"Average","title":"RDS CPU"}}
		,{"type":"metric","x":0,"y":12,"width":24,"height":6,
		 "properties": {"metrics": [["AWS/AutoScaling","GroupInServiceInstances","AutoScalingGroupName","${aws_autoscaling_group.app.name}"],["AWS/AutoScaling","GroupDesiredCapacity","AutoScalingGroupName","${aws_autoscaling_group.app.name}"]],"period":300,"stat":"Average","title":"ASG Instances (in-service vs desired)"}}
	]
}
DASH
}