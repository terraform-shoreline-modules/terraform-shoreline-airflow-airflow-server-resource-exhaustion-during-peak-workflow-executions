

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