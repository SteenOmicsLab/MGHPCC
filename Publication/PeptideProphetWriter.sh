#!/bin/bash

source /project/Path-Steen/MGHPCC/settings.sh
outputdirectory=/project/Path-Steen/results/TestMZBIN/

export JAVA_OPTS=-Djava.io.tmpdir=/project/Path-Steen/PeptideProphetTemp/

#similair to MSFragger, we will download all MSFragger items, as well as the files to the local /tmp/

#Make new directories
mkdir -p /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
mkdir -p /tmp/peptideprophet"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/

##Copy Msfragger, give chmods
cp -r $msfraggerdirectory/* /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod 770 -R /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod u+x /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher/philosopher

echo "input files are, which will be copied to Node:"

#List the files in the /tmp/timstoffiles directory
files=$1

cp -r $files /tmp/peptideprophet"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/

cd /tmp/peptideprophet"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --nocheck

#PeptideProphet Run
$philosopherPath peptideprophet --decoyprobs --ppm --accmass --nonparam --expectscore --decoy $decoyPrefix --database $fastaFile $(find /tmp/peptideprophet"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/ -name "*.pepXML")

#CP Results Back
cp -r /tmp/peptideprophet"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/* $outputdirectory

#Remove the created directories
rm -r /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
rm -r /tmp/peptideprophet"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
#Done
