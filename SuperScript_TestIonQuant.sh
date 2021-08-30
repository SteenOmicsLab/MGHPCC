#!/bin/bash

#Load Singularity on the Node
module load singularity

Commandz="singularity exec --bind /project/:/project/ /project/Path-Steen/ubunty /project/Path-Steen/ShellScripts/TestIonQuant.sh $1"

eval "$Commandz" > $1/log.txt &
until grep -q "Updating Philosopher" $1/log.txt
do
	sleep 5
	echo "Not found...."
done
 
echo "All Quants indexed. Will exit now"

kill








