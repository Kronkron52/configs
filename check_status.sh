#!/bin/bash
log_output=$(docker logs einfahrt -n 10 | grep "Обновление статусов доступности ЦОД")

# Извлечение значения для NODE1
node1_status=$(echo "$log_output" | grep -o 'NODE1=Availability[^}]*' | awk -F', ' '{print $2}' | awk -F'=' '{print $2}')

# Извлечение значения для NODE2
node2_status=$(echo "$log_output" | grep -o 'NODE2=Availability[^}]*' | awk -F', ' '{print $2}' | awk -F'=' '{print $2}')

echo "NODE1=$node1_status"
echo "NODE2=$node2_status"
