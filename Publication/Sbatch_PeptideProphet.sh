#!/bin/bash

#SBatch script for the PeptideProphet

#SBATCH --partition=mghpcc-compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=4:00:00 		#1 hours
#SBATCH --job-name=PeptideProphet 		#Job name
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=2		#Number of CPUS needed
#SBATCH --mem=4GB			#Memory needed	
#SBATCH --output=/project/Path-Steen/logs/PeptideProphet_%A_%a.log #first %A is masterjobID, %a for array (task) ID

#Load singularity
module load singularity
source /project/Path-Steen/MGHPCC/settings.sh
outputdirectory=/project/Path-Steen/results/TestMZBIN/

#Import the array
arr=("$@")

#execute script with Philosopher Container
singularity exec --bind /project/:/project/ /project/Path-Steen/testy /project/Path-Steen/MGHPCC/PeptideProphetWriter.sh "${arr[$SLURM_ARRAY_TASK_ID]}"