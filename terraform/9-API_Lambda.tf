# Resource aws_iam_role, aws_iam_policy, archive_file, aws_lambda_function, aws_iam_role_policy_attachment

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "Lambdapolicy" {
  name        = "Lambdapolicy"
  description = "Lambda Autoscaling policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:PutScalingPolicy",
          "autoscaling:UpdateAutoScalingGroup"
        ],
        "Resource": "arn:aws:autoscaling:*:333988654930:autoScalingGroup:*:autoScalingGroupName/*"
      },
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
            "kms:Decrypt",
            "autoscaling:DescribeAutoScalingGroups"
        ],
        "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = "aws_iam_role.iam_for_lambda.name"
  policy_arn = "arn:aws:iam::333988654930:policy/Lambdapolicy"
}


data "archive_file" "lambda_zip" {                                                                                                                                                                                   
  type        = "zip"                                                                                                                                                                                                
  source_file  = "script/lambdascript.py"                                                                                                                                                                                         
  output_path = "script/lambda_package.zip"                                                                                                                                                                         
}   

resource "aws_lambda_function" "LambdaAutoscaling" {
  filename = data.archive_file.lambda_zip.output_path  
  function_name = "lambda_Autoscaling"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambdascript.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("script/lambda_package.zip")

  runtime = "python3.9"

}

resource "aws_apigatewayv2_api" "Runner_lambda_api" {
  name          = "Runner_lambda_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "Runner_lambda_api" {
  api_id = aws_apigatewayv2_api.Runner_lambda_api.id

  name        = "LambdaAutoscaling"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "LambdaAutoscaling" {
  api_id = aws_apigatewayv2_api.Runner_lambda_api.id

  integration_uri    = aws_lambda_function.LambdaAutoscaling.invoke_arn
  integration_type   = "Lambda"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "LambdaAutoscaling" {
  api_id = aws_apigatewayv2_api.Runner_lambda_api.id

  route_key = "POST $default"
  target    = "integrations/${aws_apigatewayv2_integration.LambdaAutoscaling.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.LambdaAutoscaling.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.Runner_lambda_api.execution_arn}/*/*"
}