#!/bin/bash


echo -e "\033[92m Check csp license\033[0m'"

csp_license=$(docker exec -it einfahrt /opt/cprocsp/sbin/amd64/cpconfig -license -view | grep Expire)


csp_days_left=$(echo "$csp_license" | awk -F ': ' '{print $2}' | awk '{print $1}')

echo -e "Expires: $csp_days_left day(s)"


echo -e "\033[92m Check jsp license\033[0m'"
jsp_license=$(docker exec -it einfahrt java -cp :/egov/java/cryptopro/* ru.CryptoPro.JCP.tools.License | grep Validity)
jsp_expires=$(echo "$jsp_license" | awk -F ': Until ' '{print $2}')

jsp_days_left=$(date -d "$jsp_expires" +%j)
current_date=$(date +%j)
jsp_days_left=$((jsp_days_left - current_date))

echo -e "Expires: $jsp_days_left day(s)"

