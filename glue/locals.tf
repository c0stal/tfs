locals {
  product     = "myproduct"
  service     = "myservice"
  environment = "dev"

  common_tags = {
    provisioned_by = "terraform"
    environment    = "dev"
  }
}
