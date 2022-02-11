#!/bin/bash

#Load singularity
module load singularity
source /project/Path-Steen/MGHPCC/settings.sh

outputdirectory=/project/Path-Steen/results/TestMZBIN/

#Make array with the bruker files
arrayOutputbruker=($(find $outputdirectory*/ -maxdepth 0 -type d ))

#Determine number of bruker files
numberOutputFiles=$(find $outputdirectory*/ -maxdepth 0 -type d | wc -l)

#Calculate the number of batches. This would be the total number of files, divided by 3. 
#Then we round down, because the last batch will also include the left over ones (if applicable)
numberOfBatches=$(($numberOutputFiles / 100))

#Calculate the modulo. We do this so that the last batch will also include the "left over" ones.
moduloOfSamples=$(($numberOutputFiles % 100))

#Calculate number of files excluding modulo minus one. This will limit the for loop so it wont run a small batch. 
numberFilesNoModulo=$(($numberOutputFiles - $moduloOfSamples - 1))

#For loop that will create array with the batches we want to run. 
#will create N amount of batches, based on the number of input samples.
#Last batch will include modulo.
declare -a jobArrayQuant=()
number=0
for i in $(seq 0 100 $numberFilesNoModulo);
do
        number=$(($number+1))
        #if modulo      
        if (( $number == $numberOfBatches))
        then
                numberOfFilesPerBatchAndModulo=$((100 + $moduloOfSamples))
                files="${arrayOutputbruker[@]:$i:$numberOfFilesPerBatchAndModulo}"
                jobArrayQuant+=("$files")
        fi

        #if not modulo
        if (( $number != $numberOfBatches))
        then
                files="${arrayOutputbruker[@]:$i:100}"
                jobArrayQuant+=("$files")
        fi
done

#Set up array number for sbatch (total number of items in array MINUS 1)
spawnQuantArrayNumber=$((${#jobArrayQuant[@]} -1))

#Start array of Sbatches.
sbatch --array=0-$spawnQuantArrayNumber /project/Path-Steen/MGHPCC/Sbatch_PeptideProphet.sh "${jobArrayQuant[@]}"
#sbatch --array=0-$spawnQuantArrayNumber -W /project/Path-Steen/MGHPCC/Sbatch_PeptideProphet.sh "${jobArrayQuant[@]}"

