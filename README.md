
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Airflow server resource exhaustion during peak workflow executions.
---

This incident type describes an issue where the Airflow server, which is used to manage and schedule workflows, is running out of resources, such as CPU, memory, or disk space, during periods of high workflow executions. This can cause delays in workflow execution or even complete failures. It is important to monitor the server's resource usage and allocate sufficient resources to ensure smooth and uninterrupted workflow execution.

### Parameters
```shell
export RESOURCE_LIMIT="PLACEHOLDER"

export THRESHOLD="PLACEHOLDER"

export CLOUD_PROVIDER="PLACEHOLDER"

export INSTANCE_NAME="PLACEHOLDER"

export INSTANCE_IP="PLACEHOLDER"

export REGION_RESOURCE_GROUP_PROJECT_NAME="PLACEHOLDER"

export ZONE_NAME="PLACEHOLDER" #GCP ONLY

export NEW_INSTANCE_TYPE="PLACEHOLDER"
```

## Debug

### Check if there are any zombie processes
```shell
ps aux | grep Z
```

### Check CPU usage
```shell
top -b -n 1 | head -n 20
```

### Check memory usage
```shell
free -h
```

### Check disk space usage
```shell
df -h
```

### Check Airflow logs for errors or warnings
```shell
tail -n 100 /var/log/airflow/*.log
```

### Check Airflow configuration for resource limits
```shell
grep -R "${RESOURCE_LIMIT}" /etc/airflow/
```

### Check if Airflow workers are consuming too many resources
```shell
ps -aux | grep airflow-worker | awk '{print $2, $4, $11}' | sort -k2 -r
```

### Check if there are any blocked I/O operations
```shell
iotop -obn2
```

### The Airflow server is running on a machine with insufficient resources, such as low memory or CPU capacity, to handle peak workflow loads.
```shell


#!/bin/bash



# Check available memory

total_mem=$(free -m | grep Mem | awk '{print $2}')

used_mem=$(free -m | grep Mem | awk '{print $3}')

free_mem=$(($total_mem - $used_mem))



if [ $free_mem -lt ${THRESHOLD} ]; then

    echo "Insufficient memory available ($free_mem MB free)."

fi



# Check CPU usage

cpu_usage=$(top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}')



if (( $(echo "$cpu_usage > ${THRESHOLD}" | bc -l) )); then

    echo "High CPU usage detected ($cpu_usage%)."

fi


```

## Repair

### Scaling up server resources: One possible remediation strategy is to increase the resources available to the Airflow server during peak execution periods. This can be done by adding more CPU, memory, or disk space to the server or by moving to a more powerful server altogether.
```shell


#!/bin/bash



# Set variables
SERVER_NAME=${INSTANCE_NAME}
SERVER_IP=${INSTANCE_IP}
RGP_NAME=${REGION_RESOURCE_GROUP_PROJECT_NAME}
NEW_INSTANCE_TYPE=${NEW_INSTANCE_TYPE}
ZONE_NAME=${ZONE_NAME}


# Check if server is online

ping -c 1 $SERVER_IP > /dev/null

if [ $? -eq 0 ]; then

    echo "Server is online"

else

    echo "Server is offline"

    exit 1

fi

# Change instance types
case ${CLOUD_PROVIDER} in
    "aws")
        # Stop the instance before modifying
        aws ec2 stop-instances --region $RGP_NAME --instance-ids $SERVER_NAME

        # Modify the instance type
        aws ec2 modify-instance-attribute --region $RGP_NAME --instance-id $SERVER_NAME --instance-type $NEW_INSTANCE_TYPE

        # Start the instance again
        aws ec2 start-instances --region $RGP_NAME --instance-ids $SERVER_NAME
        ;;
    "azure")
        az vm resize --resource-group $RGP_NAME --name $SERVER_NAME --size $NEW_INSTANCE_TYPE
        ;;
    "gcp")
        gcloud compute instances set-machine-type $SERVER_NAME --machine-type $NEW_INSTANCE_TYPE --project $RGP_NAME --zone=$ZONE_NAME
        ;;
    *)
        echo "Error unsupported cloud provider! Supported cloud providers [aws, azure, gcp]."
        exit 1
esac


```