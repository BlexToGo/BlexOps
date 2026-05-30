resource "google_storage_bucket" "tofu_state" {
  name     = "blexops-tofu-state"
  location = "europe-west1"

  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}
