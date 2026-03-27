resource "aws_security_group" "lambda_egress" {
  count       = local.vpc_name_configured ? 1 : 0
  name        = format("%s-lambda-egress", local.base_name)
  description = "Allow proper egress for lambda to communicate with necessary services"
  vpc_id      = data.aws_vpc.vpc[var.vpc_info["vpc_name"]].id

  dynamic "egress" {
    for_each = { for x, y in local.egress_default : x => y }
    content {
      description = egress.value["description"]
      from_port   = egress.value["from_port"]
      to_port     = egress.value["to_port"]
      cidr_blocks = egress.value["cidr_blocks"]
      protocol    = egress.value["protocol"]
    }
  }
  tags = merge(jsondecode(data.template_file.global_tags_map.rendered),
  tomap({ "Name" = format("%s-lambda-egress", local.base_name) }))
}

resource "aws_security_group_rule" "egress_custom_rules" {
  count = length(var.egress_custom_rules)

  security_group_id = aws_security_group.lambda_egress[0].id
  type              = "egress"

  description = var.egress_custom_rules[count.index]["description"]
  from_port   = var.egress_custom_rules[count.index]["from_port"]
  to_port     = var.egress_custom_rules[count.index]["to_port"]
  cidr_blocks = var.egress_custom_rules[count.index]["cidr_blocks"]
  protocol    = var.egress_custom_rules[count.index]["protocol"]
  depends_on = [
    aws_security_group.lambda_egress
  ]
}
