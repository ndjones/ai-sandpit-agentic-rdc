# providers.tf

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.52.1"
    }
  }
}

# The provider will automatically use the OS_* environment variables
# that direnv has set for you. No credentials need to be in this file.
provider "openstack" {
}