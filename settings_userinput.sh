#!/bin/bash

####################################################################################################################################
#
#User should change some of the paths here. This is based on which versions of msfragger/philosopher/ionquant the user wants to use.
#
####################################################################################################################################

#Path for running over network (only for IonQuant). Please specify where IonQuant, philosopher can be found, as well as the whole fragpipe(msfragger) directory.
ionquantNetworkPath="/project/Path-Steen/msfragger/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.7.2-jar-with-dependencies.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
philosopherNetworkPath="/project/Path-Steen/msfragger/tools/philosopher/philosopher"
msfraggerdirectory="/project/Path-Steen/msfragger/"

#Please ONLY update MSFragger version. One can also change the decoy prefix if required.
msfraggerPath="/tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/MSFragger-20171106/MSFragger-3.1.1/MSFragger-3.1.1.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
fraggerParamsPath="/tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/fragger.params"
philosopherPath="/tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
ionquantPath="/tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.7.2-jar-with-dependencies.jar"
outputPath="/tmp/outputfiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/"
decoyPrefix="rev_"
philosopherNonArrayPath="/tmp/msfragger"$SLURM_JOBID"/tools/philosopher/philosopher"


# DO NOT CHANGE BELOW!! CODE WILL DO THIS MANUALLY!!!!!
inputdirectory=INPUTDIRECTORY
outputdirectory=OUTPUTDIRECTORY
fastaFile=FASTAFILE









