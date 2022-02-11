#!/bin/bash

#SBatch script for the SuperScript.sh

#SBATCH --partition=mghpcc-compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=12:00:00 		#12 hours. Normal search (i.e. tryptic, Oxidation and acetylation) will take +- 2 hours with 30 input files...
#SBATCH --job-name=MSfragger 		#Job name
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=6		#Number of CPUS needed
#SBATCH --mem=32GB			#Memory needed	
#SBATCH --output=/project/Path-Steen/logs/MSfragger_%A_%a.log #first %A is masterjobID, %a for array (task) ID

#Load singularity
module load singularity

#Import the array
arr=("$@")

#execute script
singularity exec --bind /project/:/project/ /project/Path-Steen/testy /project/Path-Steen/MGHPCC/MSfragger.sh "${arr[$SLURM_ARRAY_TASK_ID]}"  


