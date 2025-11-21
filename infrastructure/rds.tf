###################################################################
# Subnet Group (use all private subnets, needs ≥2 for Multi-AZ)
###################################################################
resource "aws_db_subnet_group" "app" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].id]
  tags       = merge(local.common_tags, { Name = "${local.name_prefix}-db-subnets" })
}

###################################################################
# KMS Key for RDS (custom encryption instead of AWS-managed key)
###################################################################
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS ${local.name_prefix}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-rds-kms" })
}

###################################################################
# Random password for DB master user
###################################################################
resource "random_password" "db" {
  length           = 20
  special          = true
  override_special = "!#$%&()*+,-.:;<=>?[]^_{|}~"
}

###################################################################
# RDS MySQL Instance
###################################################################
resource "aws_db_instance" "app" {
  identifier                = "${local.name_prefix}-mysql"
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = "db.t3.micro"
  allocated_storage         = 20
  storage_type              = "gp3"
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.rds.arn

  db_subnet_group_name      = aws_db_subnet_group.app.name
  vpc_security_group_ids    = [aws_security_group.db.id]

  username                  = "admin"
  password                  = random_password.db.result
  db_name                   = "mydb"
  port                      = 3306

  multi_az                  = true
  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot     = true

  deletion_protection       = false
  skip_final_snapshot       = true   

  publicly_accessible       = false
  apply_immediately         = true   

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-rds" })
}

###################################################################
# KMS Key for Secrets Manager (optional – separate from RDS key)
###################################################################
resource "aws_kms_key" "secret" {
  description             = "KMS key for DB credentials secret ${local.name_prefix}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-secret-kms" })
}

###################################################################
# Secret storing DB connection info (JSON)
###################################################################
resource "aws_secretsmanager_secret" "db" {
  name       = "${local.name_prefix}-db-credentials"
  kms_key_id = aws_kms_key.secret.arn
  tags       = merge(local.common_tags, { Name = "${local.name_prefix}-db-secret" })
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db.result
    engine   = "mysql"
    host     = aws_db_instance.app.address
    port     = 3306
    dbname   = "mydb"
  })
  depends_on = [aws_db_instance.app]  
}