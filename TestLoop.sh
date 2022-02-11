#!/bin/bash

#find all pepXML from MSFragger
#MSFraggerResults=$(find /project/Path-Steen/results/TestMZBIN/*/*.pepXML -maxdepth 0 -type f)

# https://stackoverflow.com/a/14387296/11375482

function max2 {
   while [ `jobs | wc -l` -ge 20 ]
   do
      sleep 5
   done
}

find /project/Path-Steen/results/TestMZBIN/*/*.pepXML -maxdepth 0 -type f | while read name ; 
do 
   max2; echo $name; sleep 5 &
done
wait

# for i in *.log ; do
#     echo $i Do more stuff here
#     sem -j+0 gzip $i ";" echo done
# done
# sem --wait