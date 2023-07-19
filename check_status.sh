#!/bin/bash
log_output=$(docker logs einfahrt -n 20 | grep -m 1 "Обновление статусов доступности ЦОД")

# Извлечение значения для NODE1
node1_status=$(echo "$log_output" | awk -F'NODE1=Availability' '{print $2}' | awk -F', ' '{print $2}' | awk -F'=' '{print $2}')

# Извлечение значения для NODE2
node2_status=$(echo "$log_output" | awk -F'NODE2=Availability' '{print $2}' | awk -F', ' '{print $2}' | awk -F'=' '{print $2}')

echo "NODE1=$node1_status"
echo "NODE2=$node2_status"
