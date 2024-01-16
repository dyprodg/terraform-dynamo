# Define the AWS API Gateway REST API
resource "aws_api_gateway_rest_api" "example" {
  name        = "ExampleAPI"
  description = "Example API using Terraform"
}

# Define a resource for the 'save' path
resource "aws_api_gateway_resource" "save" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "save"
}

# Define a resource for the '{name}' path parameter
resource "aws_api_gateway_resource" "name" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_resource.save.id
  path_part   = "{name}"
}

# Define the POST method for the '{name}' resource
resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.name.id
  http_method   = "POST"
  authorization = "NONE"
}

# Define the Lambda permission for the API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.postfunction.function_name
  principal     = "apigateway.amazonaws.com"
}

# Define the integration between the API Gateway and the Lambda function
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.name.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.postfunction.invoke_arn
}

# Define the method response for the POST method
resource "aws_api_gateway_method_response" "post_response" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.name.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
}

# Define the integration response for the POST method
# Make sure that the integration is set up before creating the integration response
resource "aws_api_gateway_integration_response" "post_response" {
  depends_on = [aws_api_gateway_integration.lambda] # Explicitly define the dependency
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.name.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_response.status_code
  response_templates = {
    "application/json" = ""
  }
}

# Define the deployment of the API Gateway
resource "aws_api_gateway_deployment" "example" {
  depends_on = [aws_api_gateway_integration.lambda, aws_api_gateway_integration_response.post_response]
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "prod"
}

# Output the URL of the deployed API Gateway
output "api_gateway_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}