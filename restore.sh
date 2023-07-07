#!/bin/bash
#-----------------------------------declare variables-----------------------------------#
declare -i fa #fa is a FAIL counter integer
vitrin=$1
ip=$2

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




#-----------------------------------Script-----------------------------------#
if [ ! $vitrin ] || [ ! $ip ]
then
  echo "You need to say what vitrin do you need. AND what SYS_TO_MAX it need to have
Format is:
./restore.sh %vitrin_name% %vitrin_ip%"
  exit 1
fi


echo "---------------Stopped csv-uploader query-execution---------------"
docker stop csv-uploader query-execution
check "Containers csv-uploader query-execution are stoppped "




not_run=$(docker ps --filter "status=exited" | grep "csv-uploader\|query-execution" | wc -l)


echo "---------------Starting $vitrin restore---------------"

if [ "$not_run" -gt 0 ]; then
	echo "---------------Transfer dump to postgress container---------------"
	docker cp ~/$vitrin-db.dump.gz postgres:/
	check "Dump transfer are done "
	echo "---------------Dump extracted from archive---------------"
	docker exec -ti postgres gzip -d /$vitrin-db.dump.gz
	check "Dump archive are done  "
	echo "---------------Doing some cleaning in postgres before restoring data---------------"
	docker exec postgres psql -U dtm -c 'SELECT pid, pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = current_database() AND pid <> pg_backend_pid();' test
	check "Cleaning in postgres are done  "
	echo "----------------Restore backed up data---------------"
	docker exec postgres pg_restore -U dtm -Fc -v --clean --create --if-exists -d postgres /$vitrin-db.dump
	check "Restore are done  "
	echo "---------------Starting everything back online---------------"
	docker start query-execution csv-uploader
	check "Containers are started  "
else
	echo "---------------Containers are not stopped---------------"
	exit 1
fi
	





#finalizing
if [[ $fa -gt 0 ]]
then
echo -e "\033[91mSCRIPT WAS FAILED!!! NEED TO CHECK EVERITHING!!! THERE WAS $fa ERROR(S)!!!\033[0m"
else
echo -e 'Everithing was done! - \033[92mOK\033[0m. Need to run DoSql script and check data from outside.'
fi
