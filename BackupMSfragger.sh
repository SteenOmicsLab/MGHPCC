#!/bin/bash

#Grab settings, set fastafile path from settings.sh
source /project/Path-Steen/ShellScripts/settings.sh

#Inputfiles
inputFiles=$1
echo "Inputfiles are:"
echo $inputFiles
echo ""

#Make new directories
mkdir -p /tmp/msfragger"$SLURM_JOBID"/
mkdir -p /tmp/timstoffiles"$SLURM_JOBID"/
mkdir -p /tmp/outputfiles"$SLURM_JOBID"/

##Copy Msfragger, give chmods
cp -r $msfraggerdirectory/* /tmp/msfragger"$SLURM_JOBID"/
chmod 770 -R /tmp/msfragger"$SLURM_JOBID"/
chmod u+x /tmp/msfragger"$SLURM_JOBID"/tools/philosopher/philosopher

#change the fragger.params so it ALSO includes the correct fastafile.
databaseTemp="database_name = "
sed -i "1s|.*|$databaseTemp$fastaFile|" $fraggerParamsPath
cat $fraggerParamsPath

#Copy the files that were input on the Sbatch/SLURM input
cp -r $1 /tmp/timstoffiles"$SLURM_JOBID"/

#Make directories for each of the .d files.
for myFile in /tmp/timstoffiles"$SLURM_JOBID"/*.d
do
	mkdir /tmp/outputfiles"$SLURM_JOBID"/$(basename ${myFile::-2})
	cd /tmp/outputfiles"$SLURM_JOBID"/$(basename ${myFile::-2})
	$philosopherPath workspace --clean --nocheck
	$philosopherPath workspace --init --nocheck
	cd ../
done

$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --nocheck

#Next, we run MSFRAGGER. change xmx for the GB on your system
java -Xmx32G -jar $msfraggerPath $fraggerParamsPath /tmp/timstoffiles"$SLURM_JOBID"/*.d

#Move the pepXML files to output directory
for myFile in  /tmp/timstoffiles"$SLURM_JOBID"/*.d
do 
	mv ${myFile::-2}.pepXML /tmp/outputfiles"$SLURM_JOBID"/$(basename ${myFile::-2})
	ls /tmp/outputfiles"$SLURM_JOBID"/$(basename ${myFile::-2})
done

#Last thing we can run in parallel is PeptideProphet. From there on it cant be parallelized (I think)
$philosopherPath peptideprophet --decoyprobs --ppm --accmass --nonparam --expectscore --decoy $decoyPrefix --database $fastaFile $(find /tmp/outputfiles"$SLURM_JOBID"/ -name "*.pepXML")

#Grab number of input directories, of .pepXML and of .pep.xml files
inputNumber=$(find $inputFiles -maxdepth 1 -name "*.d" | wc -l)
pepXMLNumber=$(find /tmp/outputfiles"$SLURM_JOBID"/*/*.pep.xml -maxdepth 1 -type f | wc -l)

#If inputNumber and pepXMLNumber are not equal it means all went fine. If not, it should not copy, and echo print that something went wrong.
if (( $inputNumber == $pepXMLNumber))
then
	#Copy results
	cp -r /tmp/outputfiles"$SLURM_JOBID"/* $outputdirectory
else
	echo "Something did go wrong. The number of .pep.xml files did not correspond with the number of samples in this batch"
fi

#Delete the directories
rm -r /tmp/msfragger"$SLURM_JOBID"/
rm -r /tmp/timstoffiles"$SLURM_JOBID"/
rm -r /tmp/outputfiles"$SLURM_JOBID"/
