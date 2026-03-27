// Render principal using AWS format 
data "external" "render_principal_aws" {
  for_each   = local.principal_list_with_account_id
  program    = [format("%s/scripts/renderPrincipal.sh", path.module)]
  query      = each.value
  depends_on = [local.principal_list_with_account_id]
}

resource "aws_lambda_permission" "invoke_permission_unqualified" {
  for_each = {
    for principal_func in local.principal_to_functions : format("%s.%s", principal_func.principal, principal_func.lambda_key) => principal_func
  }

  action        = "lambda:InvokeFunction"
  principal     = data.external.render_principal_aws[each.value["principal"]].result.principal
  function_name = aws_lambda_function.default[each.value["lambda_key"]].arn
  depends_on = [
    aws_lambda_alias.alias,
    aws_lambda_function.default
  ]
}

// Create the individual lambda permissions for each of the principal being granted access.
resource "aws_lambda_permission" "invoke_permission_qualified" {
  for_each = {
    for principal_alias in local.principal_to_aliases : format("%s.%s", principal_alias.principal, principal_alias.alias_key) => principal_alias
  }

  action        = "lambda:InvokeFunction"
  principal     = data.external.render_principal_aws[each.value["principal"]].result.principal
  function_name = aws_lambda_alias.alias[each.value["alias_key"]].function_name
  qualifier     = aws_lambda_alias.alias[each.value["alias_key"]].name
  depends_on = [
    aws_lambda_alias.alias,
    aws_lambda_function.default,
    aws_lambda_permission.invoke_permission_unqualified
  ]
}