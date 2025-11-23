###################################################################
# WAF (Web ACL) for ALB
###################################################################

resource "aws_cloudwatch_log_group" "waf" {
  name              = "/aws/waf/${local.name_prefix}-web-acl"
  retention_in_days = 7
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-waf-logs" })
}

resource "aws_wafv2_web_acl" "app" {
  name        = "${local.name_prefix}-web-acl"
  description = "WAF for ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-webacl"
    sampled_requests_enabled   = true
  }

  # Managed rule groups must use override_action
  rule {
    name     = "AWSCommon"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "SQLi"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "BadInputs"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # Rate limiting is a direct statement → action block is valid
  rule {
    name     = "RateLimit"
    priority = 4
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-web-acl" })
}

resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = aws_lb.app.arn
  web_acl_arn  = aws_wafv2_web_acl.app.arn
}

// WAF logging requires a Kinesis Firehose delivery stream ARN; a CloudWatch Log Group ARN is not valid.
// Temporarily disabled until a Firehose stream is provisioned.
// resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
//   resource_arn            = aws_wafv2_web_acl.app.arn
//   log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs.arn]
// }
