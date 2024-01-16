resource "aws_dynamodb_table" "names" {
  name           = "ExampleTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Id"
  attribute {
    name = "Id"
    type = "S"  
  }

  tags = {
    Name = "ExampleTable"
  }
}
