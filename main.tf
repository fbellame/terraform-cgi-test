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
 }

resource "google_monitoring_alert_policy" "alert_policy" {
  for_each = { for item in local.yaml_data : item.source => item }

  project      = each.value.source
  display_name = each.value.name
  conditions {
    display_name = "Condition Display Name"

    condition_threshold {
      filter     = each.value.conditions[0].condition_threshold.filter
      duration   = each.value.conditions[0].condition_threshold.duration
      comparison = each.value.conditions[0].condition_threshold.comparison

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  combiner = "OR"
  enabled  = true
}