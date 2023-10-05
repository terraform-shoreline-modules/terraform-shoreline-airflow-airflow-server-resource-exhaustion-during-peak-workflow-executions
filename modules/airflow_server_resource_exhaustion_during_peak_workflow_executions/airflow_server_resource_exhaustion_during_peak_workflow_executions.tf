resource "shoreline_notebook" "airflow_server_resource_exhaustion_during_peak_workflow_executions" {
  name       = "airflow_server_resource_exhaustion_during_peak_workflow_executions"
  data       = file("${path.module}/data/airflow_server_resource_exhaustion_during_peak_workflow_executions.json")
  depends_on = [shoreline_action.invoke_check_memory_cpu_usage,shoreline_action.invoke_change_instance_type]
}

resource "shoreline_file" "check_memory_cpu_usage" {
  name             = "check_memory_cpu_usage"
  input_file       = "${path.module}/data/check_memory_cpu_usage.sh"
  md5              = filemd5("${path.module}/data/check_memory_cpu_usage.sh")
  description      = "The Airflow server is running on a machine with insufficient resources, such as low memory or CPU capacity, to handle peak workflow loads."
  destination_path = "/agent/scripts/check_memory_cpu_usage.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "change_instance_type" {
  name             = "change_instance_type"
  input_file       = "${path.module}/data/change_instance_type.sh"
  md5              = filemd5("${path.module}/data/change_instance_type.sh")
  description      = "Scaling up server resources: One possible remediation strategy is to increase the resources available to the Airflow server during peak execution periods. This can be done by adding more CPU, memory, or disk space to the server or by moving to a more powerful server altogether."
  destination_path = "/agent/scripts/change_instance_type.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_memory_cpu_usage" {
  name        = "invoke_check_memory_cpu_usage"
  description = "The Airflow server is running on a machine with insufficient resources, such as low memory or CPU capacity, to handle peak workflow loads."
  command     = "`chmod +x /agent/scripts/check_memory_cpu_usage.sh && /agent/scripts/check_memory_cpu_usage.sh`"
  params      = ["THRESHOLD"]
  file_deps   = ["check_memory_cpu_usage"]
  enabled     = true
  depends_on  = [shoreline_file.check_memory_cpu_usage]
}

resource "shoreline_action" "invoke_change_instance_type" {
  name        = "invoke_change_instance_type"
  description = "Scaling up server resources: One possible remediation strategy is to increase the resources available to the Airflow server during peak execution periods. This can be done by adding more CPU, memory, or disk space to the server or by moving to a more powerful server altogether."
  command     = "`chmod +x /agent/scripts/change_instance_type.sh && /agent/scripts/change_instance_type.sh`"
  params      = ["INSTANCE_NAME","REGION_RESOURCE_GROUP_PROJECT_NAME","INSTANCE_IP","ZONE_NAME","NEW_INSTANCE_TYPE","CLOUD_PROVIDER"]
  file_deps   = ["change_instance_type"]
  enabled     = true
  depends_on  = [shoreline_file.change_instance_type]
}

