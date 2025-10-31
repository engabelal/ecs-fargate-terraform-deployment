resource "aws_dynamodb_table" "urls" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_code"

  attribute {
    name = "short_code"
    type = "S"
  }

  tags = {
    Name        = var.table_name
    Environment = var.environment
  }
}
