#!/bin/bash

#Load Singularity on the Node
module load singularity

#Make directories on the NVMe memory of the Node
#mkdir -p /project/Path-Steen/analysis/workspace/
#mkdir -p /tmp/outputfiles/



echo "All copies done. Will now start container"

#Run the Container
singularity exec --bind /project/:/mnt/ /project/Path-Steen/ubunty /mnt/Path-Steen/ShellScripts/ProtPrep_abacus.sh

echo 'container done. Will copy results and remove stuff from Node'

#Copy to /project/Path-Steen/analysis/outputfiles_temp2/
#cp -r /project/Path-Steen/analysis/workspace/* /project/Path-Steen/analysis/outputfiles_temp2/
#cp -r /tmp/outputfiles/ /project/Path-Steen/analysis/outputfiles_temp2/

#Remove Stuff from the NVMe of Node

#rm -r /tmp/outputfiles
#rm -r /project/Path-Steen/analysis/workspace/

echo 'done' 

#done



































