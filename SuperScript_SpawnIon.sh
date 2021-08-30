#!/bin/bash

for d in /project/Path-Steen/analysis/workspace_temp/* ; do
    sbatch Sbatch_IonquantSpawns.sh $d
    sleep 2	
done














