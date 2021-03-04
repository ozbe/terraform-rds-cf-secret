output "secret_arn" {
  value = aws_cloudformation_stack.rds.outputs["SecretARN"]
}

output "random_password" {
  value = random_password.password.result
}

# TODO - (if this works) rds instance host, user