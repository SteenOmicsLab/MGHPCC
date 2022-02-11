#!/bin/bash

#Have to set the LC_ALL. Not really sure why?
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source /project/Path-Steen/MGHPCC/settings.sh

#Run a simple for loop that will call the easypqp container to convert some files
# used a simple sleep throttle here. This can likely be optimized, but even with 3000+ files this would take less than 4 hours
#Which is fine for our case.
for resultsfile in /project/Path-Steen/results/IMPACC_Phase123_SpecLib/*.pepXML ;
do
	filename=$(basename ${resultsfile::-7})
	echo $filename
	singularity exec --bind /project/:/project/ /project/Path-Steen/easypqp easypqp convert --max_delta_unimod 0.02 --max_delta_ppm 15.0 --fragment_types '['"'"'b'"'"','"'"'y'"'"',]' --enable_unannotated --pepxml /project/Path-Steen/results/IMPACC_Phase123_SpecLib/interact-"$filename".pep.xml --spectra /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename"_uncalibrated.mgf --exclude-range -1.5,3.5 --psms /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename".psmpkl --peaks /project/Path-Steen/analysis/timstoffiles_IMPACC/"$filename".peakpkl &
	sleep 2
done


#singularity exec --bind /project/:/project/ /project/Path-Steen/easypqp easypqp library --psmtsv psm.tsv --peptidetsv peptide.tsv --out easypqp_lib_openswath.tsv --rt_lowess_fraction 0.0 pskmpeakpkl.txt