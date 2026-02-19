################################
# IAM Role for Lambda
################################

resource "aws_iam_role" "lambda_role" {
  name = "github-trigger-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

################################
# CloudWatch Logs Policy
################################

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

################################
# Lambda Function
################################

resource "aws_lambda_function" "github_trigger" {
  filename         = "lambda.zip"
  function_name    = "github-workflow-trigger"
  role             = aws_iam_role.lambda_role.arn
  handler          = "ingest.lambda_handler"
  runtime          = "python3.10"

  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      REPO  = "sachinsatale0415-stack/State-level-Liquor-Sales-Analytics"
      TOKEN = var.github_token
    }
  }
}


################################
# Allow S3 to trigger Lambda
################################

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::groups-raw-data"
}

################################
# S3 Trigger
################################

resource "aws_s3_bucket_notification" "raw_upload_trigger" {
  bucket = "groups-raw-data"

  lambda_function {
    lambda_function_arn = aws_lambda_function.github_trigger.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
