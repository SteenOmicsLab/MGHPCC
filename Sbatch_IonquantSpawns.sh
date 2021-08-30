#!/bin/bash

#SBatch script for the SuperScript.sh

#SBATCH --partition=mghpcc-compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=2:00:00 		#5 days which is the max?
#SBATCH --job-name=$1		#Job name
#SBATCH --mail-type=BEGIN,END,FAIL	
#SBATCH --mail-user=patrick.vanzalm@childrens.harvard.edu
#SBATCH --nodes=1 			#Number of Nodes needed
#SBATCH --cpus-per-task=2		#Number of CPUS needed
#SBATCH --mem=32GB			#Memory needed	

#Run the actual script in an Srun
/project/Path-Steen/ShellScripts/SuperScript_TestIonQuant.sh $1 

