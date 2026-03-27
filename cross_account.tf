// Create the individual lambda permissions for each of the accounts being granted access.
resource "aws_lambda_permission" "cross_account" {
  for_each = {
    for acp in local.account_cross_product : format("%s.%s", acp.account_name, acp.alias_name) => acp
  }
  action        = "lambda:InvokeFunction"
  principal     = format("arn:aws:iam::%s:root", each.value["account_id"])
  function_name = each.value["lambda_arn"]
  qualifier     = each.value["qualifier"]

  depends_on = [
    aws_lambda_alias.alias,
    aws_lambda_function.default
  ]
}

resource "aws_lambda_permission" "cross_account_add_permission" {
  for_each = {
    for acp in local.account_cross_product : format("%s.%s", acp.account_name, acp.alias_name) => acp
  }
  action        = "lambda:AddPermission"
  principal     = format("arn:aws:iam::%s:root", each.value["account_id"])
  function_name = each.value["lambda_arn"]
  qualifier     = each.value["qualifier"]

  depends_on = [
    aws_lambda_alias.alias,
    aws_lambda_function.default
  ]
}

resource "aws_lambda_permission" "cross_account_allow_gateway" {
  for_each = {
    for acp in local.account_cross_product : format("%s.%s", acp.account_name, acp.alias_name) => acp
  }
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = format("arn:aws:execute-api:%s:%s:*/*/*", var.region, each.value["account_id"])
  function_name = each.value["lambda_arn"]
  qualifier     = each.value["qualifier"]

  depends_on = [
    aws_lambda_alias.alias,
    aws_lambda_function.default
  ]
}