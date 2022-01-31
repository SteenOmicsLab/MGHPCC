#!/bin/bash

#SBatch script for the SuperScript.sh

#SBATCH --partition=mghpcc-compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=12:00:00 		#12 hours. Normal search (i.e. tryptic, Oxidation and acetylation) will take +- 2 hours with 30 input files...
#SBATCH --job-name=easypqp 		#Job name
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=6		#Number of CPUS needed
#SBATCH --mem=32GB			#Memory needed	
#SBATCH --output=/project/Path-Steen/logs/easypqp_%A.log #first %A is masterjobID, %a for array (task) ID

#Load singularity
module load singularity

#Have to set the LC_ALL. Not really sure why?
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source /project/Path-Steen/MGHPCC/settings.sh

#Run a simple for loop that will call the easypqp container to convert some files
# used a simple sleep throttle here. This can likely be optimized, but even with 3000+ files this would take less than 4 hours
#Which is fine for our case.
for resultsfile in /project/Path-Steen/results/IMPACC_Phase123_SpecLib/*/ ;
do
	filename=$(basename ${resultsfile})
	singularity exec --bind /project/:/project/ /project/Path-Steen/easypqp easypqp convert --max_delta_unimod 0.02 --max_delta_ppm 15.0 --fragment_types '['"'"'b'"'"','"'"'y'"'"',]' --enable_unannotated --pepxml /project/Path-Steen/results/IMPACC_Phase123_SpecLib/"$filename"/"$filename".pepXML --spectra /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename"_uncalibrated.mgf --exclude-range -1.5,3.5 --psms /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename".psmpkl --peaks /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename".peakpkl &
	sleep 4
done


