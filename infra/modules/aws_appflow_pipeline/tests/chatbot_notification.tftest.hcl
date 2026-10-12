# Guards the Slack (Amazon Q Developer) alert template. EventBridge only
# substitutes placeholders written literally as <name>; jsonencode() escapes
# them to <name>, which is why Slack showed "<flow_name>" verbatim.

mock_provider "aws" {}

variables {
  name                     = "test-flow"
  chatbot_alerts_topic_arn = "arn:aws:sns:us-east-1:123456789012:chatbot-alerts"
  source_connector_type    = "Salesforce"
  source_config = {
    salesforce = { object = "Account" }
  }
  destination_connector_type = "S3"
  destination_config = {
    s3 = { bucket_name = "test-bucket" }
  }
}

run "placeholders_are_not_escaped" {
  command = plan

  assert {
    condition     = strcontains(aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_template, "<flow_name>") && strcontains(aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_template, "<exec_id>")
    error_message = "input_template must contain literal <flow_name> and <exec_id> placeholders."
  }

  assert {
    condition     = !strcontains(aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_template, "\\u003c")
    error_message = "input_template contains \\u003c — angle brackets were escaped (jsonencode?), so EventBridge will not substitute them."
  }
}

run "every_placeholder_has_an_input_path" {
  command = plan

  assert {
    condition = alltrue([
      for p in regexall("<([A-Za-z0-9_.-]+)>", aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_template) :
      contains(keys(aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_paths), p[0])
    ])
    error_message = "input_template references a placeholder that is not defined in input_paths."
  }
}

run "error_comes_from_detail_error" {
  command = plan

  # Field name confirmed from a captured "AppFlow End Flow Run Report" event; it is
  # "error", not "errors".
  assert {
    condition     = aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_paths["error"] == "$.detail.error"
    error_message = "The error placeholder must read $.detail.error."
  }
}

run "rendered_message_is_valid_chatbot_json" {
  command = plan

  # Substitute the placeholders the way EventBridge does (a placeholder inside a
  # JSON string gets the value JSON-escaped), then parse the result. The sample
  # error has quotes and newlines, like real Salesforce errors.
  assert {
    condition = jsondecode(replace(replace(replace(
      aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_template,
      "<flow_name>", "test-flow"),
      "<exec_id>", "abc-123"),
      "<error>", trimsuffix(trimprefix(jsonencode("Details: [{\"message\":\"\\nNo such column 'X__c'\"}]"), "\""), "\""))
    ).content.description == "Flow test-flow failed (Execution ID: abc-123)\n*Error:* Details: [{\"message\":\"\\nNo such column 'X__c'\"}]"
    error_message = "Rendered description does not contain the substituted flow name, execution ID and error."
  }

  assert {
    condition = (
      jsondecode(aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_template).version == "1.0" &&
      jsondecode(aws_cloudwatch_event_target.appflow_error_chatbot[0].input_transformer[0].input_template).source == "custom"
    )
    error_message = "Template must follow the Amazon Q Developer custom notification schema (version 1.0, source custom)."
  }
}
