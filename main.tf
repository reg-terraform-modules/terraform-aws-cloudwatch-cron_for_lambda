locals { 
    service_name     = join("_", [var.module_prefix,var.module_name])
    cron_name        = join("-", [basename(var.parent_module_path), local.service_name])
}
# Generates a cloudwatch event rule to trigger lambda
resource "aws_cloudwatch_event_rule" "this" {
  name                = local.cron_name
  schedule_expression = var.cron_expression
  description         = var.description
  tags                = var.resource_tags
}

# Assigns the cloudwath event rule to the lambda target
resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = var.lambda_function_arn
}

# Generates the permission for cloudwatch to invoke the lambda function
resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}