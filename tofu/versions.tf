terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    onepassword = {
      source  = "1password/onepassword"
      version = "~> 3.0"
    }
  }

  backend "gcs" {
    bucket = "blexops-tofu-state"
    prefix = "tofu/state"
  }
}
