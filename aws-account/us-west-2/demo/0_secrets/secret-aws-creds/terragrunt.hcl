generate "custom-output" {
  path = "outputs.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF

  output "access_key" {
    value = var.aws_access_key
    sensitive = true
  }

  output "secret_access_token" {
    value = var.aws_secret_key
    sensitive = true
  }
EOF
}

terraform {
  source = pathexpand("../../../../../modules/aws")
}

inputs = {
  aws_access_key = "why-would-i-share-this-with-you"
  aws_secret_key = "why-would-i-share-this-with-you"
}
