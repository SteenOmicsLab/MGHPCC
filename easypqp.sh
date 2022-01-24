#!/bin/bash

#Have to set the LC_ALL. Not really sure why?
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source /project/Path-Steen/MGHPCC/settings.sh

module load singularity

# NEED TO THROTTLE!
#We want to throttle the easypqp (i think)
for resultsfile in /project/Path-Steen/results/IMPACC_Phase123_SpecLib/*/ ;
do
	filename=$(basename ${resultsfile})
	singularity exec --bind /project/:/project/ /project/Path-Steen/easypqp easypqp convert --max_delta_unimod 0.02 --max_delta_ppm 15.0 --fragment_types '['"'"'b'"'"','"'"'y'"'"',]' --enable_unannotated --pepxml /project/Path-Steen/results/IMPACC_Phase123_SpecLib/"$filename"/"$filename".pepXML --spectra /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename"_uncalibrated.mgf --exclude-range -1.5,3.5 --psms /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename".psmpkl --peaks /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename".peakpkl &
done

