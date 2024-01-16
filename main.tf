

resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-functions"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket]

  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}



data "archive_file" "lambda_post_function" {
  type = "zip"

  source_dir  = "${path.module}/function"
  output_path = "${path.module}/function.zip"
}

resource "aws_s3_object" "lambda_post_function" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "function.zip"
  source = data.archive_file.lambda_post_function.output_path

  etag = filemd5(data.archive_file.lambda_post_function.output_path)
}