#!/bin/bash

#SBatch script for the SuperScript.sh

#SBATCH --partition=mghpcc-compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=120:00:00 		#5 days which is the max?
#SBATCH --job-name=MSFragger		#Job name
#SBATCH --mail-type=BEGIN,END,FAIL	
#SBATCH --mail-user=patrick.vanzalm@childrens.harvard.edu
#SBATCH --output=output_MSFRAGGER.txt	#Name of the output file
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=96		#Number of CPUS needed
#SBATCH --mem=180GB			#Memory needed	

#Run the actual script in an Srun
/project/Path-Steen/ShellScripts/SuperScript.sh

