terraform {
  cloud {
    organization = "gci-test-org"

    workspaces {
      name = "gci-test-ws"
    }
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

 locals {
   yaml_data = yamldecode(file("config.yaml"))
 }

 provider "google" {
   credentials = file("credentials.json")

   project = local.yaml_data.source
   region  = "us-central1"
   zone    = "us-central1-c"
 }

 resource "google_monitoring_alert_policy" "alert_policy" {
   project      = local.yaml_data.source
   display_name = local.yaml_data.name
   conditions {
     display_name = "Condition Display Name"

     condition_threshold {
       filter     = local.yaml_data.conditions[0].condition_threshold.filter
       duration   = local.yaml_data.conditions[0].condition_threshold.duration
       comparison = local.yaml_data.conditions[0].condition_threshold.comparison
       aggregations {
         alignment_period = "60s"
         per_series_aligner = "ALIGN_RATE"  # required
       }
     }
   }
   combiner = "OR"
   enabled  = true
 }

