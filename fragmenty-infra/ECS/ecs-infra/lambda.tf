resource "aws_iam_role" "lambda_exec_role" {
  name = "ScrapyLambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "ScrapyLambdaExecutionPolicy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# resource "aws_s3_bucket" "example_bucket" {
#   bucket = "lambda-fn-fragmenty"
# }

# resource "aws_s3_bucket_acl" "example_bucket" {
#   bucket = aws_s3_bucket.example_bucket.id
#   acl    = "private"
# }

# resource "aws_s3_object" "lambda_deployment_package" {
#   bucket       = aws_s3_bucket.example_bucket.id
#   key          = "your_zip_file_key"
#   source       = "lambda_package.zip"
#   etag         = filemd5("lambda_package.zip")
#   acl          = "private"
#   content_type = "application/zip"
# }

resource "aws_lambda_function" "scrapy_lambda" {
  function_name = "ScrapyLambdaFunction"
  # s3_bucket     = aws_s3_object.lambda_deployment_package.bucket
  # s3_key        = aws_s3_object.lambda_deployment_package.key
  # handler       = "fragmenty.lambda_handler.lambda_handler" # Replace with your Scrapy handler function
  # runtime       = "python3.9"                               # Ensure you are using a supported Python runtime for your Scrapy project
  role = aws_iam_role.lambda_exec_role.arn

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.scrapy_lambda_repository.repository_url}:${var.lambda_container_image_name}"

  depends_on = [null_resource.push_spider_image]

  timeout     = 120 # Adjust the timeout based on your project's requirements
  memory_size = 256 # Adjust the memory size based on your project's requirements

  environment {
    variables = {
      MONGO_URI = var.mongo_uri
    }
  }
}

resource "aws_cloudwatch_event_rule" "scrapy_lambda_schedule" {
  name                = "ScrapyLambdaSchedule"
  description         = "Trigger Scrapy Lambda function on a schedule"
  schedule_expression = "rate(30 minutes)" # Adjust the schedule based on your desired frequency
}

resource "aws_cloudwatch_log_group" "scrapy_lambda_schedule" {
  name              = "/aws/lambda/ScrapyLambdaFunction"
  retention_in_days = 7 # Change this value to the desired number of days

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_cloudwatch_event_target" "scrapy_lambda_schedule_target" {
  rule      = aws_cloudwatch_event_rule.scrapy_lambda_schedule.name
  target_id = "ScrapyLambda"
  arn       = aws_lambda_function.scrapy_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_events" {
  statement_id  = "AllowCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scrapy_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scrapy_lambda_schedule.arn
}
