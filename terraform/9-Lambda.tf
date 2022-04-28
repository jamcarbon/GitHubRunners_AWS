# Resource aws_iam_role, aws_iam_policy, archive_file, aws_lambda_function, aws_iam_role_policy_attachment

resource "aws_iam_role" "lambdarole" {
  name = "lambda_role"

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
        "Sid": "VisualEditor1",
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

resource "aws_iam_role_policy_attachment" "Lambdapolicy" {
  role       = aws_iam_role.lambdarole.name
  policy_arn = aws_iam_policy.Lambdapolicy.arn
}


data "archive_file" "lambda_zip" {                                                                                                                                                                                   
  type        = "zip"                                                                                                                                                                                                
  source_file  = "script/lambdascript.py"                                                                                                                                                                                         
  output_path = "script/lambda_package.zip"                                                                                                                                                                         
}   

resource "aws_lambda_function" "LambdaAutoscaling" {
  filename = data.archive_file.lambda_zip.output_path  
  function_name = "lambda_Autoscaling"
  role          = aws_iam_role.lambdarole.arn
  handler       = "lambdascript.lambda_handler"

  source_code_hash = filebase64sha256("script/lambda_package.zip")

  runtime = "python3.9"

}