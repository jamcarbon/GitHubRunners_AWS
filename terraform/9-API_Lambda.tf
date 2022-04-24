# Resource
resource "random_pet" "lambda_bucket_name" {
  prefix = "s3-buvket-lambda"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

  acl           = "private"
  force_destroy = true
}

# Input variable definitions

data "archive_file" "lambda_script" {
  type = "zip"

  source_dir  = "${path.module}/GitHubRunners_AWS"
  output_path = "${path.module}/lambdascript.zip"
}

resource "aws_s3_object" "lambdascript" {
  bucket = aws_s3_bucket.lambdascript.id

  key    = "lambdascript.zip"
  source = data.archive_file.lambdascript.output_path

  etag = filemd5(data.archive_file.lambdascript.output_path)
}

resource "aws_iam_role" "lambdaAutoScalingRole"{
    name = "lambdascriptrole"
    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "25836999",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:PutScalingPolicy",
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": "arn:aws:autoscaling:*:333988654930:autoScalingGroup:*:autoScalingGroupName/*"
        },
        {
            "Sid": "2583693",
            "Effect": "Allow",
            "Action": "autoscaling:DescribeAutoScalingGroups",
            "Resource": "*"
        }
    ]})
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambdaAutoScalingRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "LambdaAutoscaling" {
  function_name = "LambdaAutoscaling"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambdascript.key

  runtime = "python3.9"
  handler = "lambda.handler"

  source_code_hash = data.archive_file.lambdascript.output_base64sha256

  role = aws_iam_role.lambdaAutoScalingRole.arn
}







resource "aws_apigatewayv2_api" "Runner_lambda_api" {
  name          = "Runner_lambda_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "Runner_lambda_api" {
  api_id = aws_apigatewayv2_api.Runner_lambda_api.id

  name        = "Runner_lambda_api_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "LambdaAutoscaling" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.LambdaAutoscaling.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "LambdaAutoscaling" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.LambdaAutoscaling.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.LambdaAutoscaling.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}