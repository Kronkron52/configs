#!/bin/bash
#-----------------------------------declare variables-----------------------------------#
declare -i fa           #fa is a FAIL counter integer
declare -i counter      #counter is counter as ever
vitrin=$1               #mnemonic_name
uvitrin=${vitrin^^}     #get UPPERCASE variant of vitrin_name
ip=$2                   #get IP from commandline


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


#-----------------------------------script_backup_vitrin-----------------------------------#
if [[ $vitrin == "etrn" ]] || [[ $vitrin == "esv" ]] || [[ $vitrin == "ezn" ]]
then
  fulldbname="mtrs_"$vitrin"_info"
elif [[ $vitrin == "epl" ]]
then
  fulldbname="f_mtrs_"$vitrin"_info"
elif [ ! $vitrin ] || [ ! $ip ]
then
  echo "You need to say what vitrin do you need. AND what IP its have.
Format is:
./backup.sh %vitrin_name% %vitrin_IP%"
  exit 1
fi

echo "---------------Processing ("mtrs_"$vitrin"_info") ---------------"
echo "---------------Processing ("mtrs_"$vitrin"_info") ---------------"

get_delta_hot=$(curl -s -X POST -H "Content-Type: application/json" -d '{"requestId": "797de19a-54e2-4c9c-af6e-a9ee312230b5","datamartMnemonic": "'$fulldbname'","sql": "get_delta_hot()"}' http://$ip:9090/query/execute | jq .empty)

if [ "$get_delta_hot" == "false" ]; then
        echo "---------------Loading in to database---------------"
		exit 1
elif [ "$get_delta_hot" == "null" ]; then
		echo "---------------Failed to check delta, check showcase name and ip---------------"
		exit 1
elif [ "$get_delta_hot" == "true" ]; then
		echo "---------------Stopped csv-uploader query-execution---------------"
		docker stop csv-uploader query-execution
		check "Containers csv-uploader query-execution are stoppped "
fi



not_run=$(docker ps --filter "status=exited" | grep "csv-uploader\|query-execution" | wc -l)


if [ "$not_run" -gt 0 ]; then
		echo "---------------Making a database dump---------------"
		docker exec -it postgres pg_dump -U dtm -w -d test -Fc -v -Z0 -f /var/lib/postgresql/data/$vitrin-db.dump 
		check "Dump its ready "
		echo "---------------Compress Dump---------------"
		docker exec -ti postgres gzip /var/lib/postgresql/data/$vitrin-db.dump
		check "Dump its done "	
		echo "---------------Download dump  in host---------------"
		docker cp postgres:/var/lib/postgresql/data/$vitrin-db.dump.gz .
		check "Dump is load "
		echo "---------------Delete dump in docker---------------"
		docker exec -ti postgres rm /var/lib/postgresql/data/$vitrin-db.dump.gz 
		check "Dump is deleted "
		echo "---------------Getting actual zookeeper data---------------"
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
		check "Doing some cleaning in data - "
		echo -e "Getting clean data:\n($DN,$DD,$DSD,$CNF,$CNT)"
		echo "---------------Starting services csv-uploader query-execution---------------"
		docker start query-execution
		check "Services started backup is done "
else
		echo "---------------Containers are not stopped---------------"
fi	



echo "---------------Create database logical---------------"
echo "---------------Create database logical---------------"
echo "---------------Create database logical---------------"



echo "---------------Processing ("mtrs_"$vitrin"_info") ---------------"
echo "---------------Processing ("mtrs_"$vitrin"_info") ---------------"

echo "$uvitrin"
echo "$uvitrin"
echo "$uvitrin"


if [ "$not_run" -gt 0 ]; then
		echo "---------------Create database logical only and stop csv-uploader---------------"
		dbname=$(curl -s -X POST -H "Content-Type: application/json" -d '{"requestId": "797de19a-54e2-4c9c-af6e-a9ee312230b5","datamartMnemonic": "'$fulldbname'","sql": "SELECT schema_name FROM INFORMATION_SCHEMA.schemata ;"}' http://$ip:9090/query/execute | jq .result[][] | grep $uvitrin | tr -d \")
		echo "$dbname"
		echo "$dbname"
		echo "$dbname"
		check "Getting dbname of $dbname "
		ufulldbname=${fulldbname^^}             # for the next selection table names must be UPPERCASE
		tablelist=$(curl -s -X POST -H "Content-Type: application/json" -d '{"requestId": "797de19a-54e2-4c9c-af6e-a9ee312230b5","datamartMnemonic": "'$fulldbname'","sql": "SELECT table_name,table_schema  FROM INFORMATION_SCHEMA.tables "}' http://$ip:9090/query/execute | jq '.result[] | select (.TABLE_SCHEMA=="'$ufulldbname'")' | grep -v $dbname | grep INFO | awk '{print $2}' | tr -d \" | tr -d ,)
		check "Getting list of tables to be processed in a new location $tablelist "
		echo "Create database $fulldbname logical_only;" > ./$vitrin-prostore-sql.sql
		check "File with prostore sql instructions created "
		echo "select max(sys_to_max)" > ./$vitrin-psql.sql
		check "File with psql instruction created "
		echo $tablelist
		for table in $tablelist
		do
		echo "processing $table.."
		got=$(curl -s -X POST -H "Content-Type: application/json" -d '{"requestId": "797de19a-54e2-4c9c-af6e-a9ee312230b5","datamartMnemonic": "'$fulldbname'","sql": "GET_Entity_ddl('$fulldbname'.'$table')"}' http://$ip:9090/query/execute | jq .result[][] | tr -d \")
		check "With $table getting:
		$got "
		echo "$got logical_only;" >> ./$vitrin-prostore-sql.sql	
		if [[ $counter -gt 0 ]]
		then                    # not the first line
		echo "union all SELECT max(sys_to) sys_to_max FROM "$fulldbname"."$table"_actual" >> ./$vitrin-psql.sql
		else                    # is the first line
		echo "from (SELECT max(sys_to) sys_to_max FROM "$fulldbname"."$table"_actual" >> ./$vitrin-psql.sql
		fi
		counter+=1
		done					
		check "File with sql instructions filled up "		
		echo "begin delta ;" >> ./$vitrin-prostore-sql.sql && echo "commit delta ;" >> ./$vitrin-prostore-sql.sql
		check "File with prostore sql instruction was finished "
		echo ") b ;" >> ./$vitrin-psql.sql
		check "File with psql instruction was finished "
		docker start csv-uploader
		check "Services started logical schemata is done "
else
		echo "---------------Containers are not stopped---------------"
		exit 1

fi


#--------------------------finalizing------------------------------
if [[ $fa -gt 0 ]]
then
echo -e "\033[91mSCRIPT WAS FAILED!!! NEED TO CHECK EVERITHING!!! THERE WAS $fa ERROR(S)!!!\033[0m"
else
echo -e 'Everithing was done! - \033[92mOK\033[0m. Need to check data from outside.'
fi