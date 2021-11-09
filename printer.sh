#!/bin/bash

#Get the given CLI directory
source /project/Path-Steen/ShellScripts/settings.sh
numberOfFilesPerBatch=$1

#Make array with the bruker files
arraybruker=($(find $inputdirectory -maxdepth 1 -name "*.d"))

#Determine number of bruker files. Currently commented because the combined.sh script has this function.
numberFiles=$(find $inputdirectory -maxdepth 1 -name "*.d" | wc -l)

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

#For loop that will create ARRAY batches based on the number of samples, split based on NumberOfFilesPerBatch that the user gives.
#The last batch will ALSO include the modulo, so that no small batch (i.e. 1 sample) will be ran.

#Make empty array
declare -a jobArray=()

#loop
number=0
for i in $(seq 0 $numberOfFilesPerBatch $numberFilesNoModulo);
do
	number=$(($number+1))
	#if i == numberOfBatches it means its the last batch, and we will include the modulo samples
	#If not, then we will just run a batch with the given number of samples
	if (( $number == $numberOfBatches))
	then
		numberOfFilesPerBatchAndModulo=$(($numberOfFilesPerBatch + $moduloOfSamples))
		files="${arraybruker[@]:$i:$numberOfFilesPerBatchAndModulo}"
	#	sbatch /project/Path-Steen/ShellScripts/Sbatch_MSfragger.sh "$files"
		jobArray+=("$files")
	fi
	
	if (( $number != $numberOfBatches))
        then
		files="${arraybruker[@]:$i:$numberOfFilesPerBatch}"
        #        sbatch /project/Path-Steen/ShellScripts/Sbatch_MSfragger.sh "$files"
		jobArray+=("$files")
	fi
done

#Set up array number for sbatch (total number of items in array MINUS 1)
msfraggerArrayNumber=$((${#jobArray[@]} -1))

#start the Sbatch array and grab the jobID number
#sbatch --array=0-$msfraggerArrayNumber /project/Path-Steen/ShellScripts/Sbatch_MSfragger.sh "${jobArray[@]}"

sbatch --array=0-$msfraggerArrayNumber -W /project/Path-Steen/ShellScripts/Sbatch_MSfragger.sh "${jobArray[@]}"

echo "@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@"
#ECHO A LOT WHEN DONE!!!!!!!
