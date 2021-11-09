#!/bin/bash

source /project/Path-Steen/ShellScripts/settings.sh

#Get the given CLI directory
numberOfFilesPerBatch=$1

#Make array with the bruker files
arraybruker=($(find $outputdirectory/*/*.pepXML -maxdepth 1 -type f ))

#Determine number of bruker files
numberFiles=$(find $outputdirectory/*/*.pepXML -maxdepth 1 -type f | wc -l)

#Make array with the bruker files
arraybrukerDir=($(find $inputdirectory -maxdepth 1 -name "*.d"))

#Determine number of bruker files
numberFilesDir=$(find $inputdirectory -maxdepth 1 -name "*.d" | wc -l)

#Check if requested batch size is not bigger than the number of files.
if (($numberFiles < $numberOfFilesPerBatch))
then
	echo "Your requested batch size is bigger than the number of samples in the directory"
	echo "ERROR"
	exit
fi

#Calculate the number of batches. This would be the total number of files, divided by the numberOfFilesPerBatch. 
#Then we round down, because the last batch will also include the left over ones (if applicable)
numberOfBatches=$(($numberFiles / $numberOfFilesPerBatch))

#Calculate the modulo. We do this so that the last batch will also include the "left over" ones.
moduloOfSamples=$(($numberFiles % $numberOfFilesPerBatch))

#Calculate number of files excluding modulo minus one. This will limit the for loop so it wont run a small batch. 
numberFilesNoModulo=$(($numberFiles - $moduloOfSamples - 1))

#For loop that will create batches based on the number of samples, split based on NumberOfFilesPerBatch that the user gives.
#The last batch will ALSO include the modulo, so that no small batch (i.e. 1 sample) will be ran.
number=0
for i in $(seq 0 $numberOfFilesPerBatch $numberFilesNoModulo);
do
	number=$(($number+1))
	#if i == numberOfBatches it means its the last batch, and we will include the modulo samples
	#If not, then we will just run a batch with the given number of samples
	if (( $number == $numberOfBatches))
	then
		numberOfFilesPerBatchAndModulo=$(($numberOfFilesPerBatch + $moduloOfSamples))
		filesDir="${arraybrukerDir[@]:$i:$numberOfFilesPerBatchAndModulo}"
		files="${arraybruker[@]:$i:$numberOfFilesPerBatchAndModulo}"
		sbatch /project/Path-Steen/ShellScripts/Sbatch_SpawnQuant.sh "$files" "$filesDir"
		#/project/Path-Steen/ShellScripts/testing/Sbatch_SpawnQuant.sh "$files" "$filesDir"
	fi
	
	if (( $number != $numberOfBatches))
        then
		filesDir="${arraybrukerDir[@]:$i:$numberOfFilesPerBatch}"
                files="${arraybruker[@]:$i:$numberOfFilesPerBatch}"
                sbatch /project/Path-Steen/ShellScripts/Sbatch_SpawnQuant.sh "$files" "$filesDir"
		#/project/Path-Steen/ShellScripts/testing/Sbatch_SpawnQuant.sh "$files" "$filesDir"
	fi
done

