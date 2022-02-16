#!/bin/bash

####################################################################################################################################
#
#User should change some of the paths here. This is based on which versions of msfragger/philosopher/ionquant the user wants to use.
#
####################################################################################################################################

#Specify Number of files per Batch
numberOfFilesPerBatch=3

#Specify Container
container="/project/Path-Steen/ubuntu_fragpipe"

#specify where the fragpipe directory is, and where each tool is for both on node and on network.
fragpipeDirectory="/project/Path-Steen/fragpipe/"

#Path for running over network (only for IonQuant). Please specify where IonQuant, philosopher can be found, as well as the whole fragpipe(msfragger) directory.
msfraggerPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/MSFragger-20171106/MSFragger-3.3/MSFragger-3.3.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
ionquantPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.7.2-jar-with-dependencies.jar"
philosopherPath="/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
msfraggerNetworkPath="/project/Path-Steen/fragpipe/MSFragger-20171106/MSFragger-3.3/MSFragger-3.3.jar"
ionquantNetworkPath="/project/Path-Steen/fragpipe/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.7.2-jar-with-dependencies.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
philosopherNetworkPath="/project/Path-Steen/fragpipe/tools/philosopher/philosopher"

#Specify decoyPrefix. Should be same as in fragger.params.
decoyPrefix="rev_"