
#python function for lambda and permissions
resource "aws_lambda_function" "DynamoDBVisitorFunction" {
  #filename      = "path to zipped python file"
  function_name = "write_item"
  role          = aws_iam_role.DynamoDBLambdaRole.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.basic-dynamodb-table.name
    }
  }
}

resource "aws_lambda_permission" "apigw-visitCounter" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.DynamoDBVisitorFunction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitorCounter.execution_arn}/*"
}
