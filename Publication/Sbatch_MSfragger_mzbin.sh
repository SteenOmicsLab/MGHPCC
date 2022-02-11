#!/bin/bash

#SBatch script for the SuperScript.sh

#SBATCH --partition=mghpcc-gpu 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=48:00:00 		#12 hours. Normal search (i.e. tryptic, Oxidation and acetylation) will take +- 2 hours with 30 input files...
#SBATCH --job-name=MSfragger 		#Job name
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=36		#Number of CPUS needed
#SBATCH --mem=180GB			#Memory needed	
#SBATCH --output=/project/Path-Steen/logs/MSfraggerMZBIN_%A_%a.log #first %A is masterjobID, %a for array (task) ID

#Load singularity
module load singularity

#Import the array
arr=("$@")

#execute script
singularity exec --bind /project/:/project/ /project/Path-Steen/testy /project/Path-Steen/MGHPCC/MSfragger_mzbin.sh

