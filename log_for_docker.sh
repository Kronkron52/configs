#!/bin/bash

NAME=$1

echo "Check for container presence, gathering log"
if [ ! -z $(docker ps -a |awk '{print $NF}'|grep "^${NAME}$") ]; then
    echo -e "Press Ctrl-C to stop log output\n\n"
    docker logs ${NAME} -f --tail=10
else
    echo "ERROR: No container process found"
    exit 1
fi


#!/bin/bash

NAME="einfahrt"

LOGFILE="log-$(date +%Y%m%d-%H%M%S).txt"

echo "Check for container presence, gathering log"
if [ ! -z $(docker ps -a |awk '{print $NF}'|grep "^${NAME}$") ]; then
    docker logs ${NAME} >${LOGFILE} 2>&1
    echo "Log file gathered; See ${LOGFILE} for details"
else
    echo "ERROR: No container process found"
    exit 1
fi


#!/bin/bash

NAME="einfahrt"
LOGFILE="log-$(date +%Y%m%d-%H%M%S).txt"
ERRORLOG="error.log"

echo "Check for container presence, gathering log" > "$LOGFILE"
if [ ! -z $(docker ps -a | awk '{print $NF}' | grep "^${NAME}$") ]; then
    docker logs "${NAME}" -n 50 >> "$LOGFILE" 2>&1
    echo "Log file gathered; See $LOGFILE for details" >> "$LOGFILE"

    echo "Filtering log for errors $LOGFILE"
    grep -i "error" "$LOGFILE" > "$ERRORLOG"
    echo "Error log file created; See $ERRORLOG for error details $LOGFILE"
else
    echo "ERROR: No container process found"
    exit 1
fi