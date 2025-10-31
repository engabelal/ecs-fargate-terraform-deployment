output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_lock.id
}

output "backend_config" {
  description = "Backend configuration to use in environments"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "ENV/terraform.tfstate"  # Replace ENV with dev/staging/prod
        region         = "${var.aws_region}"
        encrypt        = true
        dynamodb_table = "${aws_dynamodb_table.terraform_lock.id}"
      }
    }
  EOT
}
