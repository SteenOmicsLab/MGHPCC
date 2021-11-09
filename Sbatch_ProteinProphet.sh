#!/bin/bash

#SBATCH --partition=mghpcc-compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=10:00:00 #120:00:00 		#2 days. I have so far not seen it need more time.
#SBATCH --job-name=ProteinProphet		#Job name
#SBATCH --mail-type=BEGIN,END,FAIL	
#SBATCH --mail-user=patrick.vanzalm@childrens.harvard.edu
#SBATCH --output=/project/Path-Steen/logs/ProteinProphet_%j.log	#Name of the output file
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=4		#Number of CPUS needed
#SBATCH --mem=16GB			#Memory needed	

#Load Singularity on the Node
module load singularity

#Run the Container
singularity exec --bind /project/:/project/ /project/Path-Steen/testy /project/Path-Steen/ShellScripts/ProteinProphet.sh  # $1




