#!/bin/bash
#SBATCH --partition=mghpcc-short 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=20:00:00 		#12 hours. Normal search (i.e. tryptic, Oxidation and acetylation) will take +- 2 hours with 30 input files...
#SBATCH --job-name=easyPQPL		#Job name
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=32		#Number of CPUS needed
#SBATCH --mem=180GB			#Memory needed	

#Have to set the LC_ALL. Not really sure why?
export LC_ALL=C

#source the settings and mzBIN arrays
source $1/settings/settings.sh
cd $1/results/

#Load Singularity on the Node
module load singularity

find $outputdirectory/results/ \( -name '*.psmpkl' -or -name '*.peakpkl' \) -print > easypqplist.txt

#Run the final Library
singularity exec --bind /project/:/project/ $easypqpContainer easypqp library --psmtsv psm.tsv --peptidetsv peptide.tsv --out easypqp_lib_openswath.tsv --rt_lowess_fraction 0.0 easypqplist.txt
