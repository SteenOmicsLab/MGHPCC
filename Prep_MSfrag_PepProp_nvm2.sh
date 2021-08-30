#!/bin/bash

#First start up Singularity in the srun
module load singularity

file=$1

#next we run the singularity
#singularity exec --bind /project:/mnt /project/Path-Steen/ubunty /mnt/Path-Steen/ddBash.sh #FragPipe_docker_Shell.sh
singularity exec --bind /project/:/mnt/ /project/Path-Steen/ubunty /mnt/Path-Steen/ShellScripts/MSfrag_PepProp_nvm2.sh $file
