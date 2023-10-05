terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "airflow_server_resource_exhaustion_during_peak_workflow_executions" {
  source    = "./modules/airflow_server_resource_exhaustion_during_peak_workflow_executions"

  providers = {
    shoreline = shoreline
  }
}