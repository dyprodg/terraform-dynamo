# Define the AWS Lambda function
resource "aws_lambda_function" "postfunction" {
  function_name = "Postname"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_post_function.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_post_function.output_base64sha512

  role = aws_iam_role.lambda_exec.arn
}

# Define the CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "postfunction_cloudwatch" {
  name = "/aws/lambda/${aws_lambda_function.postfunction.function_name}"

  retention_in_days = 30
}

# Define the IAM role for the Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach the AWSLambdaBasicExecutionRole policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define the IAM policy for the Lambda function to access DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "LambdaDynamoDBPolicy"
  description = "IAM policy for Lambda to access DynamoDB"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "dynamodb:PutItem", 
        "dynamodb:UpdateItem" 
      ],
      Effect   = "Allow",
      Resource = aws_dynamodb_table.names.arn
    }]
  })
}

# Attach the custom DynamoDB policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
  role       = aws_iam_role.lambda_exec.name
}



