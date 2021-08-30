#!/bin/bash

#singularity exec --bind /project:/mnt /project/Path-Steen/ubunty /mnt/Path-Steen/ddBash.sh #FragPipe_docker_Shell.sh
singularity exec --bind /project/:/mnt/ /project/Path-Steen/ubunty /mnt/Path-Steen/ShellScripts/MSfragger1.sh
