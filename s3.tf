data "aws_s3_bucket" "list" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.s3_trigger) == true
  }
  bucket = each.value["s3_trigger_bucket"]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.s3_trigger) == true
  }
  bucket = data.aws_s3_bucket.list[each.key].id
  lambda_function {
    lambda_function_arn = format("%s:%s", local.lambda_short_name_to_arn_mapping[each.key],
    local.lambda_merged[each.key]["s3_trigger_alias"])
    events        = split(",", each.value["s3_trigger_event"])
    filter_prefix = local.lambda_merged[each.key]["s3_trigger_prefix"]
    filter_suffix = local.lambda_merged[each.key]["s3_trigger_suffix"]
  }
  depends_on = [
    aws_iam_policy.s3_policy,
    aws_iam_role_policy_attachment.s3_policy_attachment
  ]
}

resource "aws_lambda_permission" "s3_lambda_permission" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.s3_trigger) == true
  }
  statement_id  = format("AllowS3Invocations_%s", each.value["s3_trigger_bucket"])
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_short_name_to_arn_mapping[each.key]
  qualifier     = local.lambda_merged[each.key]["s3_trigger_alias"]
  principal     = "s3.amazonaws.com"
  source_arn    = format("arn:aws:s3:::%s", data.aws_s3_bucket.list[each.key].id)
}

resource "aws_iam_policy" "s3_policy" {
  for_each    = length(local.s3_bucket_ids) > 0 ? { "write" = true } : {}
  name        = format("s3-lambda-trigger-policy-%s", local.base_name)
  description = "S3 access policy for lambda"
  policy      = data.template_file.s3_policy.rendered
}

data "template_file" "s3_policy" {
  template = file(format("%s/templates/s3-policy.json.tmpl", path.module))
  vars = {
    bucketArns = jsonencode(concat(formatlist("arn:aws:s3:::%s", local.s3_bucket_ids),
    formatlist("arn:aws:s3:::%s/*", local.s3_bucket_ids)))
  }
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  for_each   = aws_iam_policy.s3_policy
  role       = aws_iam_role.role[0].name
  policy_arn = each.value.arn
}
