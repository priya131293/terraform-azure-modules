module "resourcegroup" {
  source = "../../"

  name        = "rg-test-app"
  location    = "East US"
  environment = "test"
  project     = "my-app"
  owner_email = "p.kumari@slalom.com"

  tags = {
    Department = "Platform_developer"
  }
}