#! /bin/bash

# arg 0
# arg 1 -> ubicacion exacta
# arg 2 -> nombre archivo 

echo >> $2;
echo $1 >> $2;
ping 200.1.21.80 -c 300 >> $2;

echo >> $2;
