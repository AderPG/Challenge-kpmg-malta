terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      #version = "~>4.6.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "orion-ad-lab"
  region = "us-central1"
  zone = "us-central1-a"
  credentials = "key-terrafom-sa.json"
}

provider "google-beta" {
  project     = "orion-ad-lab"
  region      = "us-central1"
  credentials = "key-terrafom-sa.json"
}

