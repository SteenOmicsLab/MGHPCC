#!/bin/bash

####################################################################################################################################
#
#User should change some of the paths here. This is based on which versions of msfragger/philosopher/ionquant the user wants to use.
#
####################################################################################################################################

#Specify Number of files per Batch
numberOfFilesPerBatch=10

#Specify Container
container="/project/Path-Steen/Patrick/Containers/ubuntu_fragpipe"
easypqpContainer="/project/Path-Steen/Patrick/Containers/easypqp"

#specify where the fragpipe directory is, and where each tool is for both on node and on network.
fragpipeDirectory="/project/Path-Steen/Patrick/Fragpipe/"

#Path for running over network (only for IonQuant). Please specify where IonQuant, philosopher can be found, as well as the whole fragpipe(msfragger) directory.
msfraggerPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/MSFragger-3.4/MSFragger-3.4.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
ionquantPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/MSFragger-3.4/IonQuant-1.7.17.jar"
philosopherPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher-4.2.1/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
msfraggerNetworkPath="/project/Path-Steen/Patrick/Fragpipe/MSFragger-3.4/MSFragger-3.4.jar"
ionquantNetworkPath="/project/Path-Steen/Patrick/Fragpipe/MSFragger-3.4/IonQuant-1.7.17.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
philosopherNetworkPath="/project/Path-Steen/Patrick/Fragpipe/tools/philosopher-4.2.1/philosopher"
msfragDBsplitPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/msfragger_pep_split.py"
msfragDBsplitNetworkPath="/project/Path-Steen/Patrick/Fragpipe/tools/msfragger_pep_split.py"

#Specify decoyPrefix. Should be same as in fragger.params.
decoyPrefix="rev_"

#Specify for large databases or semi-sepcifiy/unspecific searches the number of splits for the database to be searched
dbsplits=1 #default is 1
