#!/bin/bash
#SBATCH --partition=mghpcc-largemem 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=239:59:00 		#12 hours. Normal search (i.e. tryptic, Oxidation and acetylation) will take +- 2 hours with 30 input files...
#SBATCH --job-name=IonQuant 		#Job name
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=96		#Number of CPUS needed
#SBATCH --mem=360GB			#Memory needed	

export LC_ALL=C

#source the settings and mzBIN arrays
source $1/settings/settings.sh

#Load Singularity on the Node
module load singularity

#Run job
singularity exec --bind $inputdirectory,$outputdirectory,$fragpipeDirectory $container $1/settings/IonQuant/IonQuant.sh "$1" 
