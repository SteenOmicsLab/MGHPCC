#!/bin/bash

#Load Singularity on the Node
module load singularity

#Run the Container
singularity exec --bind /project/:/mnt/ /project/Path-Steen/ubunty /mnt/Path-Steen/ShellScripts/IonQuant.sh

echo 'container done. Will copy results and remove stuff from Node'

echo 'done' 

#done

