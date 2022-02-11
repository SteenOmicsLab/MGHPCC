#!/bin/bash

#SBatch script for the SuperScript.sh

#SBATCH --partition=mghpcc-compute 		#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=240:00:00 		#5 days which is the max?
#SBATCH --job-name=IonQuant		#Job name
#SBATCH --mail-type=BEGIN,END,FAIL	
#SBATCH --mail-user=patrick.vanzalm@childrens.harvard.edu
#SBATCH --output=/project/Path-Steen/logs/IonQuant%j	#Name of the output file
#SBATCH --nodes=1 			#Number of Nodes needed
#SBATCH --cpus-per-task=96		#Number of CPUS needed
#SBATCH --mem=180GB			#Memory needed	

#Load Singularity on the Node
module load singularity

#Run the Container
singularity exec --bind /project/:/project/ /project/Path-Steen/testy /project/Path-Steen/ShellScripts/IonQuant.sh

