# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals  {
  region = "us-west-2"
  availability_zones = ["us-west-2a","us-west-2b","us-west-2c"]
}