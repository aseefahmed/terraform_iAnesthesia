resource "aws_s3_bucket" "archives" {
    bucket_prefix = "anesthesia-archives-"
    lifecycle_rule {
        id = "rule-1"

        expiration {
        days = 90
        }

        enabled = true
    }
    
}