#!/bin/bash

#Load Singularity on the Node
module load singularity


#Copy the fragpipe files to msfragger directory
cp -r /project/Path-Steen/msfragger/ /tmp/msfragger/

#make msfraggerfiles executable
chmod 770 -R /tmp/msfragger/
chmod u+x /tmp/msfragger/tools/philosopher/philosopher

echo "All copies done. Will now start container"

#Run the Container
singularity exec --bind /project/:/mnt/ /project/Path-Steen/ubunty /mnt/Path-Steen/ShellScripts/ProtPrep.sh

echo 'container done. Will copy results and remove stuff from Node'

#Remove Stuff from the NVMe of Node
rm -r /tmp/msfragger

echo 'done' 




































