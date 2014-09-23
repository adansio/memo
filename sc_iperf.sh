#! /bin/bash

echo $1 >> m.e2;
iperf -c 200.1.26.100 -i 1 -t 30 >> m.e2;

sleep 1;

iperf -c 200.1.26.100 -i 1 -t 30 -p 5002 -u -b 5M >> m.e2;
echo >> m.e2;

exit
