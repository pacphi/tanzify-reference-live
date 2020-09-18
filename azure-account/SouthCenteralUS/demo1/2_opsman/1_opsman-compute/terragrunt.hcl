locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load opsman variables
  opsman_vars = read_terragrunt_config("opsman_vars.hcl")

  # Extract the variables we need for easy access
  opsman_build = local.opsman_vars.locals.opsman_build
  opsman_version = local.opsman_vars.locals.opsman_version

  # Extract the variables we need for easy access
  location   = local.region_vars.locals.location
  environment_name = local.environment_vars.locals.environment_name
  hosted_zone = local.environment_vars.locals.hosted_zone
  cloud_name = local.account_vars.locals.cloud_name
}

dependency "creds" {
  config_path = "../../0_secrets/secret-azure-creds"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    azure_subscription_id = "fake"
    azure_tenant_id = "fake"
    azure_client_id = "fake"
    azure_client_secret = "fake"
  }
}

dependency "paving" {
  config_path = "../../1_infra/2_paving"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    ops_manager_ssh_public_key = "fake"
    ops_manager_storage_account_name = "fake"
    ops_manager_container_name = "fake"
    ops_manager_dns = "fake"
    ops_manager_private_ip = "fake"
    resource_group_name = "fake"
    ops_manager_security_group_name = "fake"
    management_subnet_id = "fake"
  }
}

terraform {

  source = "git::git@github.com:abhinavrau/tanzify-infrastructure.git//azure/azure-opsman-compute"
}

inputs = {
  location   = local.region_vars.locals.location
  environment_name = local.environment_vars.locals.environment_name
  hosted_zone = local.environment_vars.locals.hosted_zone
  cloud_name = local.account_vars.locals.cloud_name

  opsman_build = local.opsman_build
  opsman_version = local.opsman_version

  tenant_id =       dependency.creds.outputs.azure_tenant_id
  subscription_id = dependency.creds.outputs.azure_subscription_id
  client_id =       dependency.creds.outputs.azure_client_id
  client_secret =   dependency.creds.outputs.azure_client_secret

  ops_manager_ssh_public_key = dependency.paving.outputs.ops_manager_ssh_public_key
  ops_manager_ssh_private_key = dependency.paving.outputs.ops_manager_ssh_private_key
  ops_manager_storage_account_name = dependency.paving.outputs.ops_manager_storage_account_name
  ops_manager_storage_container_name = dependency.paving.outputs.ops_manager_container_name
  ops_manager_dns = dependency.paving.outputs.ops_manager_dns

  ops_manager_private_ip = dependency.paving.outputs.ops_manager_private_ip
  resource_group_name = dependency.paving.outputs.resource_group_name
  ops_manager_security_group_name = dependency.paving.outputs.ops_manager_security_group_name
  subnet_id = dependency.paving.outputs.management_subnet_id


}