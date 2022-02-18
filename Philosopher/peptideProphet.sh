#!/bin/bash
export LC_ALL=C

#specify the three inputs
sourcefile=$1
SLURM_JOBID=$2
SLURM_ARRAY_TASK=$3

#Grab settings, set fastafile path from settings.sh
source $1/settings/settings.sh

#Load the array that is written in the combined.sh script.
arr=()
while IFS= read -r line; do
   arr+=("$line")
done <$1/settings/write_MZbin.txt

# Echo so that in case goes wrong we can re-find
echo "${arr[$SLURM_ARRAY_TASK_ID]}"

# #Make tmp directories
mkdir -p /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
mkdir -p /tmp/results"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/

#copy result directories with pepXML to /tmp
for myFile in ${arr[$SLURM_ARRAY_TASK_ID]}
do
	cp -r $outputdirectory/results/$(basename ${myFile::-2}) /tmp/results"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
done

#Copy fragpipe
cp -r $fragpipeDirectory/* /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod 777 -R /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod u+x /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher/philosopher

#set up Philosopher workspace in this temp folder
cd /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --temp /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/ --nocheck

#run peptideProphet
$philosopherPath peptideprophet --decoyprobs --ppm --accmass --nonparam --expectscore --decoy $decoyPrefix --database $fastaFile $(find /tmp/results"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/ -name "*.pepXML")

#identify the number of pepXML and pep.xml
pepXMLnumber=$(find /tmp/results"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/*/*.pepXML -type f | wc -l)
pep_xmlnumber=$(find /tmp/results"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/*/*.pep.xml -type f | wc -l)

#if numberOfFilesPerBatch is not equal to number of mzBIN something went wrong and we throw error. Otherwise, the copy the mzBIN files over.
#If inputNumber and pepXMLNumber are not equal it means all went fine. If not, it should not copy, and echo print that something went wrong.
if (( $pepXMLnumber == $pep_xmlnumber))
then
	#Copy mzBIN and .mgf
	cp -r /tmp/results"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/* $outputdirectory/results/
   #Remove /tmp files
   rm -r /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
   rm -r /tmp/results"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
   echo "all pep.xml files created succesfully"
   exit 0
else
	echo "Something did go wrong. no match between number of pepXML and pep.xml files"
   #Remove /tmp files
   rm -r /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
   rm -r /tmp/results"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"
   exit 1
fi
