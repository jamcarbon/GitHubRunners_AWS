# Resource


resource "aws_iam_policy" "LambdaAutoscaling" {
  name = "LambdaAutoscaling"
  arn = "arn:aws:iam::123456789012:policy/UsersManageOwnCredentials"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
			"autoscaling:SetDesiredCapacity",
			"autoscaling:PutScalingPolicy",
			"autoscaling:UpdateAutoScalingGroup",
			"autoscaling:DescribeAutoScalingGroups"
		]
        Effect = "Allow"
        Resource = "lambda.amazonaws.com"
      },
    ]
  })
}

resource "aws_iam_role" "LambdaAutoScalingRole" {
  name = "LambdaAutoScalingRole"
  assume_role_policy  = aws_iam_policy.LambdaAutoscaling.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.LambdaAutoScalingRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {                                                                                                                                                                                   
  type        = "zip"                                                                                                                                                                                                
  source_file  = "script/lambdascript.py"                                                                                                                                                                                         
  output_path = "script/lambda_package.zip"                                                                                                                                                                         
}   
resource "aws_lambda_function" "LambdaAutoscaling" {
  description = "LambdaAutoscaling"
  function_name = "LambdaAutoscaling"
  filename = data.archive_file.lambda_zip.output_path  
  runtime = "python3.9"
  handler = "lambdascript.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role = aws_iam_role.LambdaAutoScalingRole.arn
  
  timeout = 15
  publish = true

  tags = {
        Developer = "David Montenegro"
    }
}

resource "aws_apigatewayv2_api" "Runner_lambda_api" {
  name          = "Runner_lambda_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "Runner_lambda_api" {
  api_id = aws_apigatewayv2_api.Runner_lambda_api.id

  name        = "Runner_lambda_api_stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "LambdaAutoscaling" {
  api_id = aws_apigatewayv2_api.Runner_lambda_api.id

  integration_uri    = aws_lambda_function.LambdaAutoscaling.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "LambdaAutoscaling" {
  api_id = aws_apigatewayv2_api.Runner_lambda_api.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.LambdaAutoscaling.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.LambdaAutoscaling.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.Runner_lambda_api.execution_arn}/*/*"
}