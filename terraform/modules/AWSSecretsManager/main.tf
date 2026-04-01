# -------------------------------------------------------
# Secrets Manager — store RDS credentials
# -------------------------------------------------------
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = var.secret_name
  description             = "RDS credentials"
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    {
      Name = "${var.identifier}-db-secret"
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}