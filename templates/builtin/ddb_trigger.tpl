{
  "lambdas": "foo",
  %{for lambda in lambda_map ~}
  "${lambda.name}: {
    "index": "${index(keys(lambda_map),each)}",
    "table_name": "%s",
    "lambda_name": "%s"
  }%{ endfor ~}
}
