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

#Copy Msfragger and fragger.params, give chmods
cp -r $fragpipeDirectory/* /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
cp $fraggerParamsNetworkPath /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod 777 -R /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod u+x /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher/philosopher

#We want to specify the pepXML files for the inputfiles from the array
files=""
for myFile in ${arr[$SLURM_ARRAY_TASK_ID]}
do
	fileTemp="$outputdirectory/results/$(basename ${myFile::-2})/$(basename ${myFile::-2}).pepXML"
   files+="$fileTemp "
done

#run writing of quantindex
java -Xmx16G -jar $ionquantPath --threads 2 --ionmobility 1\
 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0 --mbrrttol 1\
  --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1 --peptidefdr 1 --normalization 1\
   --minisotopes 2 --writeindex 1 --tp 3 --minfreq 0.5 --minions 1 --minexps 1\
    --specdir $inputdirectory $files

#Check if all are written
for myFile in ${arr[$SLURM_ARRAY_TASK_ID]}
do	
   # #If inputNumber and pepXMLNumber are not equal it means all went fine. If not, it should not copy, and echo print that something went wrong.
   if test -f "$inputdirectory/$(basename ${myFile::-2}).quantindex"
   then
      echo "$(basename ${myFile::-2}).quantindex found and written"
   else
      echo "$(basename ${myFile::-2}).quantindex not found. Will throw error."
      rm -r /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
      exit 1
   fi
done
echo "All Quantindex files found"
rm -r /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
exit 0
