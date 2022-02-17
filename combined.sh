#!/bin/bash

# This is the script to run all Fragpipe tools in a parallelized manner on a HPC.
# By Patrick van Zalm (patrick.vanzalm@childrens.harvard.edu / patrickvanzalm@gmail.com)
# Steen lab, Boston Childrens's Hospital, Boston, Massachussets, United States of America

#### NOTE ####
# A User should ALWAYS first fill in the required settings in the settings.sh file 
# before running the script below.

# Script requires five inputs:
# 1. Input Directory
# 2. Output Directory
# 3. FASTA file
# 4. Fragger.params file
# 5. Location of all the scripts

inputdirectory=$1
outputdirectory=$2
fastaFile=$3
fraggerparamsFile=$4
ScriptsLocation=$5

#check if inputdirectory is a directory. If not; kill process
if [[ ! -d "$inputdirectory" ]]
then
	echo "ERROR"
	echo "Input argument 1(inputdirectory) is not a directory"
	echo "Please make sure you refer to an existing directory"
	kill $$ 
fi

#Determine the number of .d bruker directories in the inputdirectory
numberFiles=$(find $inputdirectory -maxdepth 1 -name "*.d" | wc -l)

#If numberFiles is 0, it means there is no bruker data and we kill process
if (($numberFiles == 0))
then
	echo "ERROR"
	echo "Directory found, but it seems there are no bruker(.d) files in the directory"
	echo "Please make sure you refer to a directory with bruker .d directories"
	kill $$
fi

#if the outputdirectory does not exist we make it ourselves.
if [[ ! -d "$outputdirectory" ]]
then
        echo "output directory not found. will make it"
	mkdir -p $outputdirectory
fi

#Check if FASTA file is correct. The file has to end with .fas or .fasta
if [[ ($fastaFile == *.fas) || ($fastaFile == *.fasta) ]]
then
       echo "Fasta file correct. Will proceed."
else
	echo "Fasta file does not seem to be correct. It did not end with .fas or .fasta"
	echo "Please make sure. Will kill script now."	
	kill $$
fi

# If this is all correct we will design the ouputdirectory
# We make a directory for the results, logs and settings
mkdir -p $outputdirectory/logs
mkdir -p $outputdirectory/settings
mkdir -p $outputdirectory/results

#copy settings.sh, fraggerparams and fasta to settings directory
cp -r $ScriptsLocation/* $outputdirectory/settings/
cp $fraggerparamsFile $outputdirectory/settings/
cp $fastaFile $outputdirectory/settings/

#chmod the scripts
chmod 770 $outputdirectory/settings/*

#all other scripts will take info from the settings.sh script. We append some info there as given by user
echo -e "\n\n# USER INPUT SETTINGS" >> $outputdirectory/settings/settings.sh
echo "ScriptsLocation=$ScriptsLocation" >> $outputdirectory/settings/settings.sh
echo "inputdirectory=$inputdirectory" >> $outputdirectory/settings/settings.sh
echo "outputdirectory=$outputdirectory" >> $outputdirectory/settings/settings.sh
echo "fastaFile=$outputdirectory/settings/$(basename ${fastaFile})" >> $outputdirectory/settings/settings.sh
echo "fraggerParamsNetworkPath=$outputdirectory/settings/$(basename ${fraggerparamsFile})" >> $outputdirectory/settings/settings.sh

#We can now source those settings.
source $outputdirectory/settings/settings.sh

#Alter the FASTA file location in the fragger.params file
databaseTemp="database_name = "
sed -i "1s|.*|$databaseTemp$fastaFile|" $fraggerParamsNetworkPath

#chmod the tools for the networkpath usage
chmod 777 -R $fragpipeDirectory
chmod u+x $philosopherNetworkPath

######################
## Prepare Batching ##
######################

#Make array with the bruker files
arraybruker=($(find $inputdirectory -maxdepth 1 -name "*.d"))

#Check if requested batch size is not bigger than the number of files.
if (($numberFiles < $numberOfFilesPerBatch))
then
	echo "ERROR"
        echo "Your requested batch size is bigger than the number of samples in the directory"
        echo "Please make sure that it is smaller (n-1)."
        kill $$
fi

#Calculate the number of batches. This would be the total number of files, divided by the numberOfFilesPerBatch. 
#Then we round down, because the last batch will also include the left over ones (if applicable)
numberOfBatches=$(($numberFiles / $numberOfFilesPerBatch))

#Calculate the modulo. We do this so that the last batch will also include the "left over" ones.
moduloOfSamples=$(($numberFiles % $numberOfFilesPerBatch))

#Calculate number of files excluding modulo minus one. This will limit the for loop so it wont run a small batch at the end.
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
                jobArray+=("$files")
        fi

        if (( $number != $numberOfBatches))
        then
                files="${arraybruker[@]:$i:$numberOfFilesPerBatch}"
                jobArray+=("$files")
        fi
done

#Write the array to a temp file so we can read it in the Sbatch script
for j in "${jobArray[@]}"
do
      echo $j 
done >$outputdirectory/settings/write_MZbin.txt

#Set up array number for sbatch (total number of items in array MINUS 1)
msfraggerArrayNumber=$((${#jobArray[@]} -1))

#determine number of mzBIN
numberFilesmzBIN=$(find $inputdirectory -maxdepth 1 -name "*.mzBIN" | wc -l)

#################
## WRITE mzBIN ##
#################

#Determine number of mzBIN files in the directory. If corresponds to number of bruker .d we run msfragger
#If not; we run the write mzbin scripts first to parallelize the writing process
if (( $numberFiles != $numberFilesmzBIN))
then
        echo "Uneven number of .d files and mzBIN files observed: will write all mzBIN first"
        sbatch --array=0-$msfraggerArrayNumber\
         --output=$outputdirectory/logs/write_mzBIN_%A_%a.log\
         -W\
         "$outputdirectory/settings/MSFragger/Sbatch_write_mzBIN.sh" "$outputdirectory"  
        echo "Writing of mzBIN finished."
fi

#################
##  MSFRAGGER  ##
#################

# mzBIN should be written. We can run MSFragger now.
echo "Run MSFragger"
sbatch --output=$outputdirectory/logs/MSFragger_%A.log\
         -W\
         "$outputdirectory/settings/MSFragger/Sbatch_MSFragger.sh" "$outputdirectory"  
echo "MSFragger finished"

####################
## peptideProphet ##
####################

# Run peptideprophet in parallel. Use same batching as for writing mzBIN
echo "Run batched peptideProphet"
sbatch --array=0-$msfraggerArrayNumber\
         --output=$outputdirectory/logs/peptideProphet_%A_%a.log\
         -W\
         "$outputdirectory/settings/Philosopher/Sbatch_peptideProphet.sh" "$outputdirectory"
echo "peptideProphet finished"

####################
## proteinProphet ##
##   databases    ##
##    filter      ##
##    report      ##
####################

#All are single threaded processes that require little computational power
echo "Run ProteinProphet, database, filter and report"
sbatch --output=$outputdirectory/logs/ProteinProphet_et_al_%A.log\
         -W\
         "$outputdirectory/settings/Philosopher/Sbatch_proteinProphet.sh" "$outputdirectory"  
echo "ProteinProphet, database, filter and report finished"

####################
##    iProphet    ##
####################

#All are single threaded processes that require little computational power
echo "Run iProphet"
sbatch --output=$outputdirectory/logs/iProphet_%A.log\
         -W\
         "$outputdirectory/settings/Philosopher/Sbatch_iProphet.sh" "$outputdirectory"  
echo "iProphet finished"


######################
## WRITE quantindex ##
######################

#determine number of quantindex
echo "Checking if all quantindex files are written...."
numberFilesquantindex=$(find $inputdirectory -maxdepth 1 -name "*.quantindex" | wc -l)

#Determine number of mzBIN files in the directory. If corresponds to number of bruker .d we run msfragger
#If not; we run the write mzbin scripts first to parallelize the writing process
if (( $numberFiles != $numberFilesquantindex))
then
        echo "Uneven number of .d files and quantindex files observed: will write all quantindex first"
        sbatch --array=0-$msfraggerArrayNumber\
         --output=$outputdirectory/logs/write_quantindex_%A_%a.log\
         -W\
         "$outputdirectory/settings/IonQuant/Sbatch_write_quantindex.sh" "$outputdirectory"  
        echo "Writing of quantindex finished."
fi
echo "All quantindex are written and/or found."

#################
##  IonQuant   ##
#################
# quantindex should be written. We can run IonQuant now.

echo "Run IonQuant"
sbatch --output=$outputdirectory/logs/IonQuant_%A.log\
         -W\
         "$outputdirectory/settings/IonQuant/Sbatch_IonQuant.sh" "$outputdirectory"  
echo "IonQuant finished"
