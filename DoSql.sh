#!/bin/bash
#-----------------------------------declare variables-----------------------------------#
declare -i fa           #fa is a FAIL counter integer
declare -i counter      #counter is counter as ever
vitrin=$1               #get vitrin_name from commandline
ip=$2                   #get IP from commandline
maxdelta=$3             #get cnTo


#-----------------------------------function check-----------------------------------#
function check {
if [ $? -eq 0 ]
then
echo -e $1 '\033[92mOK\033[0m'
else
echo -e $1 '\033[91mFAIL\033[0m'
fa+=1 #fastes way to increase integer by 1
fi
}

#-----------------------------------starting stage-----------------------------------
if [[ $vitrin == "etrn" ]] || [[ $vitrin == "esv" ]] || [[ $vitrin == "ezn" ]]
then
  fulldbname="mtrs_"$vitrin"_info"
elif [[ $vitrin == "epl" ]]
then
  fulldbname="f_mtrs_"$vitrin"_info"
elif [ ! $vitrin ] || [ ! $ip ] || [ ! $maxdelta ]
then
  echo "You need to say what vitrin do you need. AND what IP its have.
Format is:
./backup.sh %vitrin_name% %vitrin_IP% %maxdelta%"
  exit 1
fi

echo "-------------------------------Create logical database----------------------------------------------"


IFS=$'\n'
for string in $(cat ./$vitrin-prostore-sql.sql)
do
echo "Executing sql: $string"
got=$(curl -s -X POST -H "Content-Type: application/json" -d '{"requestId": "797de19a-54e2-4c9c-af6e-a9ee312230b5","datamartMnemonic": "'$fulldbname'","sql": "'$string'"}' http://$ip:9090/query/execute | jq .result[][] | tr -d \")
check "and getting: 
$got  "
done



echo "-------------------------------create is done---------------------------------"
docker cp ./$vitrin-psql.sql postgres:/
systomax=$(docker exec -ti postgres psql -Udtm test -f /$vitrin-psql.sql | sed -n -e 3p)
check "Executing in postgres sql and getting sys_to_max ($systomax) "
docker exec -ti postgres rm ./$vitrin-psql.sql


echo "starting tune zookeeper data..."
check "Vitrin fullname - $fulldbname - "
DN=$(docker exec -it zookeeper bin/zkCli.sh get /adtm/test/$fulldbname/delta | grep deltaNum | jq .ok.deltaNum)
check "get raw DeltaNum - $DN - "
DD=$(docker exec -it zookeeper bin/zkCli.sh get /adtm/test/$fulldbname/delta | grep deltaNum | jq .ok.deltaDate)
check "get raw DeltaDateD - $DD - "
DSD=$(docker exec -it zookeeper bin/zkCli.sh get /adtm/test/$fulldbname/delta | grep deltaNum | jq .ok.deltaServerDate)
check "get raw eltaServerDate - $DSD - "
CNF=$(docker exec -it zookeeper bin/zkCli.sh get /adtm/test/$fulldbname/delta | grep deltaNum | jq .ok.cnFrom)
check "get raw CN FROM - $CNF - "
CNT=$(docker exec -it zookeeper bin/zkCli.sh get /adtm/test/$fulldbname/delta | grep deltaNum | jq .ok.cnTo)
check "get raw CN TO - $CNT - "

DN=$(echo $DN | tr -d " ") && DD=$(echo $DD | tr -d " ") && DSD=$(echo $DSD | tr -d " ") && CNF=$(echo $CNF | tr -d " ") && CNT=$(echo $CNT | tr -d " ")
check "doing some cleaning in data - "

if [ $CNT -eq $maxdelta ] #, then this is not the vitrin, you need to stop the script!
#if ^ true, then execute:
then
  echo "Wrong vitrin or maxdelta, or something else. Exiting"
  exit 1
else
  COMMAND=\{\"hot\":null,\"ok\":\{\"deltaNum\":$DN,\"deltaDate\":$DD,\"deltaServerDate\":$DSD,\"cnFrom\":$CNF,\"cnTo\":$maxdelta\}\}
  docker exec -it zookeeper bin/zkCli.sh set /adtm/test/$fulldbname/delta $COMMAND
  check "write delta data to zookeeper - "
  NCNT=$(docker exec -it zookeeper bin/zkCli.sh get /adtm/test/$fulldbname/delta | grep deltaNum | jq .ok.cnTo)
  check "get NEW raw CN TO - $NCNT - "
fi


if [ $NCNT -eq $maxdelta ]
then 
  echo "Done!"
else
  echo "Need to check everything!"
fi


#finalizing
if [[ $fa -gt 0 ]]
then
echo -e "\033[91mSCRIPT WAS FAILED!!! NEED TO CHECK EVERITHING!!! THERE WAS $fa ERROR(S)!!!\033[0m"
else
echo -e 'Everithing was done! - \033[92mOK\033[0m. Need to check data from outside.'
fi
