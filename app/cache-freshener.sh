#!/bin/bash

LINKED_CONTAINER_NAME=ip-list

# get the port from the linked container
PORT=$(echo ${IP_LIST_PORT}|cut -f 3 -d:)
echo "Connecting to the IP list service on port ${PORT}"

# Get the list of endpoints
ENDPOINTS=$(curl -s ${LINKED_CONTAINER_NAME}:${PORT} | grep li |awk -F '[<>]' '{print $5}')

# write the base html file
curl -s ${LINKED_CONTAINER_NAME}:${PORT} > /json/index.html

# Loop forever, sleeping for our frequency
while true
do
  echo "Refreshing cache"

  for ENDPOINT in $ENDPOINTS
  do
    echo "processing endpoint ${ENDPOINT}"
    # curl -s -w "\nTimings: connect:%{time_connect} starttransfer:%{time_starttransfer} total:%{time_total}\n" ${LINKED_CONTAINER_NAME}:${PORT}/${ENDPOINT}
    curl -s ${LINKED_CONTAINER_NAME}:${PORT}/${ENDPOINT} > /json/${ENDPOINT}.tmp
    mv /json/${ENDPOINT}.tmp /json/${ENDPOINT}
  done

  sleep 30
done

exit 0
