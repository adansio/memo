#! /bin/bash

echo $1 >> m.e2;
iperf -c <ip_server> -i 1 -t 30 >> m.e2;
sleep 1;
iperf -c <ip_server> -i 1 -t 30 -p 5002 -u -b 70M >> m.e2;
echo >> m.e2;
exit
