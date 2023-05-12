#!/bin/bash

IP_ADDR="8.8.8.8"
LOG_FILE="/tmp/$IP_ADDR.log"

echo "Monitoring $IP_ADDR..."

while true; do
ping -c 1 $IP_ADDR > /dev/null
if [ $? -ne 0 ]; then
echo "$(date) $IP_ADDR is not reachable." >> $LOG_FILE
echo "lock" > notreach.lck
sleep 1
else
if [ -f notreach.lck ]; then
echo "$(date) $IP_ADDR is reachable." >> $LOG_FILE
rm -f notreach.lck > /dev/null
fi
sleep 10
fi
done
