#!/bin/bash

####################################################################################################################################
#
#User should change some of the paths here. This is based on which versions of msfragger/philosopher/ionquant the user wants to use.
#
####################################################################################################################################

#Specify Container locations
container="/project/Path-Steen/Patrick/Containers/ubuntu_fragpipe"
easypqpContainer="/project/Path-Steen/Patrick/Containers/easypqp"

#specify where the fragpipe directory is, and where each tool is for both on node and on network.
fragpipeDirectory="/project/Path-Steen/Patrick/Fragpipe/"

#Specify location and version of the Fragpipe tools.
msfraggerNetworkPath="/project/Path-Steen/Patrick/Fragpipe/MSFragger-3.4/MSFragger-3.4.jar"
ionquantNetworkPath="/project/Path-Steen/Patrick/Fragpipe/MSFragger-3.4/IonQuant-1.7.17.jar" 
philosopherNetworkPath="/project/Path-Steen/Patrick/Fragpipe/tools/philosopher-4.2.1/philosopher"
msfragDBsplitNetworkPath="/project/Path-Steen/Patrick/Fragpipe/tools/msfragger_pep_split.py"

#Specify version of tools. DO NOT CHANGE THE $SLURM_JOBID and $SLURM_ARRAY_TASK_ID part!!
msfraggerPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/MSFragger-3.4/MSFragger-3.4.jar" 
ionquantPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/MSFragger-3.4/IonQuant-1.7.17.jar"
philosopherPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher-4.2.1/philosopher" 
msfragDBsplitPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/msfragger_pep_split.py"

#Specify decoyPrefix. Should be same as in fragger.params.
decoyPrefix="rev_"

#Specify Number of files per Batch used throughout.
numberOfFilesPerBatch=10

#Specify for large databases or semi-sepcifiy/unspecific searches the number of splits for the database to be searched
dbsplits=1 #default is 1