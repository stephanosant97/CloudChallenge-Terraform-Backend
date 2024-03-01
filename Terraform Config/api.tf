 #api established
 resource "aws_api_gateway_rest_api" "visitorCounter" {
  name        = "visitorCounter"
  api_key_source = "HEADER"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#path for methods
resource "aws_api_gateway_resource" "cors_resource" {
  path_part   = "resources"
  parent_id   = aws_api_gateway_rest_api.visitorCounter.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
}

#get method
resource "aws_api_gateway_method" "increment_visitors_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitorCounter.id
  resource_id   = aws_api_gateway_resource.cors_resource.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = false
}

#get method response
resource "aws_api_gateway_method_response" "method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.increment_visitors_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
  depends_on = [aws_api_gateway_method.increment_visitors_method]
}

#integration
resource "aws_api_gateway_integration" "lambda_visitor_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitorCounter.id
  resource_id             = aws_api_gateway_resource.cors_resource.id
  http_method             = aws_api_gateway_method.increment_visitors_method.http_method
  integration_http_method = "POST"
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  type                    = "AWS"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = aws_lambda_function.DynamoDBVisitorFunction.invoke_arn
}


#integration response
resource "aws_api_gateway_integration_response" "VisitorIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.increment_visitors_method.http_method
  status_code = aws_api_gateway_method_response.method_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'https://www.stephanosant.com'"
  }

  depends_on = [
    aws_api_gateway_integration.lambda_visitor_integration
  ]
}

#deployement for stage
resource "aws_api_gateway_deployment" "visitor_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  triggers = {
    "redeployment" = sha1(jsonencode([
      aws_api_gateway_resource.cors_resource.id,
      aws_api_gateway_method.increment_visitors_method.http_method,
      aws_api_gateway_integration.lambda_visitor_integration.id,
      aws_api_gateway_method_response.method_response_200.id
    ]))
  }
}

#live stage
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.visitor_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitorCounter.id
  stage_name    = "default"
  cache_cluster_enabled = false
  cache_cluster_size = "0.5"
  xray_tracing_enabled = false
}


#throttling
resource "aws_api_gateway_usage_plan" "incrementVisitor-UsagePlan" {
  name = "visitorCount_usage_plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.visitorCounter.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }
}


#options for CORS
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitorCounter.id
  resource_id   = aws_api_gateway_resource.cors_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
  api_key_required = false
}

#cors response
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = false,
    "method.response.header.Access-Control-Allow-Methods" = false,
    "method.response.header.Access-Control-Allow-Headers" = false
  }
  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [aws_api_gateway_method.options_method]
}

#cors integration
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  connection_type      = "INTERNET"
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200

        depends_on = [aws_api_gateway_method.options_method]
      }
    )
  }
}

#cors response
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitorCounter.id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://www.stephanosant.com/'"
  }
  depends_on = [aws_api_gateway_method_response.options_200]
}


resource "aws_api_gateway_model" "tfer1" {
  content_type = "application/json"
  description  = "This is a default error schema model"
  name         = "Error"
  rest_api_id  = "${aws_api_gateway_rest_api.visitorCounter.id}"
  schema       = "{\n  \"$schema\" : \"http://json-schema.org/draft-04/schema#\",\n  \"title\" : \"Error Schema\",\n  \"type\" : \"object\",\n  \"properties\" : {\n    \"message\" : { \"type\" : \"string\" }\n  }\n}"
}

resource "aws_api_gateway_model" "tfer2" {
  content_type = "application/json"
  description  = "This is a default empty schema model"
  name         = "Empty"
  rest_api_id  = "${aws_api_gateway_rest_api.visitorCounter.id}"
  schema       = "{\n  \"$schema\": \"http://json-schema.org/draft-04/schema#\",\n  \"title\" : \"Empty Schema\",\n  \"type\" : \"object\"\n}"
}

