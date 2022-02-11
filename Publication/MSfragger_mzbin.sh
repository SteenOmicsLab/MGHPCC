#!/bin/bash

#Have to set the LC_ALL. Not really sure why?
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source /project/Path-Steen/MGHPCC/settings.sh

#TEST
mkdir -p /project/Path-Steen/results/TestMZBIN/
outputdirectory=/project/Path-Steen/results/TestMZBIN/

# #Make new directories
mkdir -p /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/

#Copy Msfragger, give chmods
cp -r $msfraggerdirectory/* /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod 777 -R /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod u+x /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher/philosopher

#change the fragger.params so it ALSO includes the correct fastafile.
databaseTemp="database_name = "
sed -i "1s|.*|$databaseTemp$fastaFile|" $fraggerParamsPath

#Make directories for each of the .d files.
# for myFile in $inputdirectory/*.d
# do
# 	mkdir $outputdirectory/$(basename ${myFile::-2})
# 	cd $outputdirectory/$(basename ${myFile::-2})
# 	$philosopherPath workspace --clean --nocheck
# 	$philosopherPath workspace --init --nocheck
# 	cd ../
# done

$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --nocheck

#Next, we run MSFRAGGER. change xmx for the GB on your system
#java -Xmx160G -jar $msfraggerPath $fraggerParamsPath $inputdirectory/*.d

#Move the pepXML files to output directory
# for myFile in  $inputdirectory/*.d
# do 
#  	mv ${myFile::-2}.pepXML $outputdirectory/$(basename ${myFile::-2})
#   cp ${myFile::-2}.pepXML $outputdirectory/$(basename ${myFile::-2})
# done

#Go to the output directory, same as in the MSFragger script
cd $outputdirectory

#Run philosopher workspace to set up.
$philosopherNonArrayPath workspace --clean --nocheck
$philosopherNonArrayPath workspace --init --nocheck
$philosopherNonArrayPath database --annotate $fastaFile --prefix $decoyPrefix

#Run ProteinProphet	
$philosopherNonArrayPath proteinprophet --maxppmdiff 2000000 --output combined $(find ./ -name "*.pep.xml")

#Delete the directories
find /tmp/ -empty -type d -delete
rm -r /tmp/msfragger"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/