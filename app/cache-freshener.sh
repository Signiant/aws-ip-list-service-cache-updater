#!/bin/bash

LINKED_CONTAINER_NAME=ip-list

# get the port from the linked container
PORT=$(echo ${IP_LIST_PORT}|cut -f 3 -d:)
echo "Connecting to the IP list service on port ${PORT}"

# Get the list of endpoints
ENDPOINTS=$(curl -s ${LINKED_CONTAINER_NAME}:${PORT} | grep li |awk -F '[<>]' '{print $5}')
echo "Retrieved endpoints: ${ENDPOINTS}"

while [ -z "${ENDPOINTS}" ]; do
  echo "No endpoints retrieved - retrying"
  ENDPOINTS=$(curl -s ${LINKED_CONTAINER_NAME}:${PORT} | grep li |awk -F '[<>]' '{print $5}')
  echo "Retrieved endpoints: ${ENDPOINTS}"
  sleep 10
done

# write the base html file
curl -s ${LINKED_CONTAINER_NAME}:${PORT} > /json/index.html
echo "Wrote base HTML file"

# Add the service-list endpoint to the list of things to update
ENDPOINTS="${ENDPOINTS} service-list healthcheck all"

# Loop forever, sleeping for our frequency
while true
do
  echo "Refreshing cache for endpoints...."

  for ENDPOINT in $ENDPOINTS
  do
    echo "processing endpoint ${ENDPOINT}"
    # curl -s -w "\nTimings: connect:%{time_connect} starttransfer:%{time_starttransfer} total:%{time_total}\n" ${LINKED_CONTAINER_NAME}:${PORT}/${ENDPOINT}
    curl -s ${LINKED_CONTAINER_NAME}:${PORT}/${ENDPOINT} > /json/${ENDPOINT}.tmp

    if [ -s "/json/${ENDPOINT}.tmp" ]; then
      mv /json/${ENDPOINT}.tmp /json/${ENDPOINT}
    else
      echo "zero byte json file detected /json/${ENDPOINT}.tmp - not moving"
    fi
  done

  # Refresh every 5 minutes (300 seconds)
  sleep 300
done

exit 0
