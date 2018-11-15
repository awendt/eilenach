###############################################
# Lambda needs an execution role it can assume,
# and it needs access to CloudWatch
###############################################
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam-for-eilenach-lambdas"
  description = "All Lambda functions for Eilenach assume this role"

  assume_role_policy = "${file("iam-for-eilenach-lambdas.json")}"
}

resource "aws_iam_role_policy" "grant_cloudwatch_access" {
  name = "grant-cloudwatch-access"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = "${file("grant-cloudwatch-access.json")}"
}

########################################################
# Define the function that is being invoked via schedule
########################################################
resource "aws_lambda_function" "bookkeeper" {
  description      = "Queries and reports account balances"
  filename         = "../src/bookkeeper/bookkeeper.zip"
  function_name    = "bookkeeper"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "bookkeeper.lambda_handler"
  runtime          = "python3.6"
  timeout          = 10

  environment {
    variables = {
      BANKING_BLZ = "${var.banking_blz}"
      BANKING_USERNAME = "${var.banking_username}"
      BANKING_PIN = "${var.banking_pin}"
      BANKING_ENDPOINT = "${var.banking_endpoint}"
    }
  }

  tags {
    "awendt:project" = "eilenach"
  }
}

########################################################################
# The above function writes account balances as JSON to CloudWatch Logs,
# so we need to turn one account balance into a CloudWatch Metric
########################################################################
resource "aws_cloudwatch_log_metric_filter" "lambda-metrics-balance-family" {
  name = "filter-account-balance-family"

  log_group_name = "/aws/lambda/bookkeeper"
  pattern        = "{ $.event = \"bookkeeper:balances:read\" }"

  metric_transformation {
    namespace = "Bookkeeper"
    name      = "account-balance-family"
    value     = "$.balances.${var.shared_account_number}"
  }
}

###########################
# Create a periodic trigger
###########################
resource "aws_cloudwatch_event_rule" "every_ten_minutes" {
  name = "every-ten-minutes"
  description = "Fires every ten minutes"
  schedule_expression = "rate(10 minutes)"
}


#############################################
# Connect the trigger to the Lambda function,
# and allow it to invoke the function
#############################################
resource "aws_cloudwatch_event_target" "read_balances_every_ten_minutes" {
  rule = "${aws_cloudwatch_event_rule.every_ten_minutes.name}"
  target_id = "bookkeeper"
  arn = "${aws_lambda_function.bookkeeper.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_bookkeeper" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.bookkeeper.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.every_ten_minutes.arn}"
}

################################
# Create an SNS topic for alarms
################################
resource "aws_sns_topic" "bookkeeper-updates" {
  name = "bookkeeper-updates"
}

########################################################
# Define the notifier function that is invoked via alarm
########################################################
resource "aws_lambda_function" "bookkeeper-mailer" {
  description      = "Sends e-mails if account balance is below certain thresholds"
  filename         = "../src/beacon/mailgun.zip"
  function_name    = "bookkeeper-mailer"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "mailgun.handler"
  runtime          = "nodejs6.10"
  timeout          = 5

  environment {
    variables = {
      MAILGUN_KEY = "${var.mailgun_key}"
      MAILGUN_DOMAIN = "${var.mailgun_domain}"
      MAIL_RECIPIENT = "${var.mail_recipient}"
    }
  }

  tags {
    "awendt:project" = "eilenach"
  }
}

#################################################
# Connect the alarm topic to the Lambda function,
# and allow it to invoke the function
#################################################
resource "aws_sns_topic_subscription" "bookkeeper-updates" {
  topic_arn = "${aws_sns_topic.bookkeeper-updates.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.bookkeeper-mailer.arn}"
}

resource "aws_lambda_permission" "allow_sns_to_call_mailer" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.bookkeeper-mailer.function_name}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.bookkeeper-updates.arn}"
}

########################################
# Create alarms for the account balances
########################################

locals {
  threshold = 500
}

resource "aws_cloudwatch_metric_alarm" "low-family-balance" {
  alarm_name                = "low-family-balance"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "3"
  metric_name               = "account-balance-family"
  namespace                 = "Bookkeeper"
  period                    = "${10 * 60}"
  statistic                 = "Average"
  threshold                 = "${local.threshold}"
  alarm_description         = "Auf dem Familienkonto sind weniger als ${local.threshold} EUR"
  alarm_actions             = ["${aws_sns_topic.bookkeeper-updates.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "no-family-balance" {
  alarm_name                = "no-family-balance"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "3"
  metric_name               = "account-balance-family"
  namespace                 = "Bookkeeper"
  period                    = "${10 * 60}"
  statistic                 = "Average"
  threshold                 = 0
  alarm_description         = "Das Familienkonto ist jetzt überzogen"
  alarm_actions             = ["${aws_sns_topic.bookkeeper-updates.arn}"]
}
