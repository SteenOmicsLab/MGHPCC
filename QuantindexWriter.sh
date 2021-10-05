#!/bin/bash

source /project/Path-Steen/ShellScripts/settings.sh

#similair to MSFragger, we will download all MSFragger items, as well as the files to the local /tmp/

#Make new directories
mkdir -p /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/

##Copy Msfragger, give chmods
cp -r $msfraggerdirectory/* /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod 770 -R /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod u+x /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher/philosopher

echo "Copying is done. Will now start IonQuant"
echo "input files are"

#List the files in the /tmp/timstoffiles directory
files=$1

echo $files

#set up some prestrings.
prestring=' --psm '
poststring='/psm.tsv'
appendstring=''
abacusstring=''
space=" "

#make the big strings. There are input for abacus and IonQuant
for myFile in $files
do
	filename=$(dirname $myFile)
	prefilenamepost=$prestring$filename$poststring
	appendstring="$appendstring$prefilenamepost"

	abacusstring="$abacusstring$filename$space"
done

cd $outputdirectory

#IonQuant Run
java -Xmx32G -jar $ionquantPath --threads 12 --ionmobility 1 --proteinquant 2 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0 --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1 --peptidefdr 1 --normalization 1 --minisotopes 2 --writeindex 1 --tp 3 --minfreq 0.5 --minions 1 --minexps 1 --specdir $inputdirectory $files

#java -Xmx32G -jar $ionquantPath --threads 12 --ionmobility 1 --mbr 1 --multidir . --proteinquant 2 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0 --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1 --peptidefdr 1 --normalization 1 --minisotopes 2 --writeindex 1 --tp 3 --minfreq 0.5 --minions 1 --minexps 1 $appendstring --specdir $inputdirectory $files

#Remove the created directories
rm -r /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/

#PeptideProphet makes a lot of small little directories on /tmp/. We do want to remove this.
find /tmp/ -empty -type d -delete

#Done
