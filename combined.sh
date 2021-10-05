#!/bin/bash
#source /project/Path-Steen/ShellScripts/settings.sh

#We grab 3!! inputs from the user: directory where .d files are. Directory where results should go, and the FASTA file.
inputdirectory=$1
outputdirectory=$2
numberOfFilesPerBatch=$3
fastaFile=$4

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

#If all directories are succesful we will now change this in the settings.sh file

#Copy the settings file which we will change based on user input.
cp settings_userinput.sh settings.sh

#Change key parameters in settings.sh based on userinput
sed -i "s|INPUTDIRECTORY|$inputdirectory|" settings.sh
sed -i "s|OUTPUTDIRECTORY|$outputdirectory|" settings.sh
sed -i "s|FASTAFILE|$fastaFile|" settings.sh

###############################
#
## MSFRAGGER + PeptideProphet
#
##############################

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

#Set up array number for sbatch (total number of items in array MINUS 1)
msfraggerArrayNumber=$((${#jobArray[@]} -1))

# Sbatch the array. the -W argument will have it wait until ALL of them are done.
sbatch --array=0-$msfraggerArrayNumber -W /project/Path-Steen/ShellScripts/Sbatch_MSfragger.sh "${jobArray[@]}"

echo "MSFragger + peptideprophet done. Will now run ProteinProphet + Philosopher"

###################
#
# ProteinProphet + Philosopher
#
##################

sbatch -W /project/Path-Steen/ShellScripts/Sbatch_ProteinProphet.sh $outputdirectory

echo "ProteinProphet + Philosopher done. Will now write .quantindex files"

##################
#
# QuantindexWriter
#
#################

#Make array with the bruker files
arrayOutputbruker=($(find $outputdirectory*/*.pepXML -maxdepth 1 -type f ))

#Determine number of bruker files
numberOutputFiles=$(find $outputdirectory*/*.pepXML -maxdepth 1 -type f | wc -l)

#Calculate the number of batches. This would be the total number of files, divided by 3. 
#Then we round down, because the last batch will also include the left over ones (if applicable)
numberOfBatches=$(($numberOutputFiles / 3))

#Calculate the modulo. We do this so that the last batch will also include the "left over" ones.
moduloOfSamples=$(($numberOutputFiles % 3))

#Calculate number of files excluding modulo minus one. This will limit the for loop so it wont run a small batch. 
numberFilesNoModulo=$(($numberOutputFiles - $moduloOfSamples - 1))

#For loop that will create array with the batches we want to run. 
#will create N amount of batches, based on the number of input samples.
#Last batch will include modulo.
declare -a jobArrayQuant=()
number=0
for i in $(seq 0 3 $numberFilesNoModulo);
do
        number=$(($number+1))
        #if modulo      
        if (( $number == $numberOfBatches))
        then
                numberOfFilesPerBatchAndModulo=$((3 + $moduloOfSamples))
                files="${arrayOutputbruker[@]:$i:$numberOfFilesPerBatchAndModulo}"
                jobArrayQuant+=("$files")
        fi

        #if not modulo
        if (( $number != $numberOfBatches))
        then
                files="${arrayOutputbruker[@]:$i:3}"
                jobArrayQuant+=("$files")
        fi
done

#Set up array number for sbatch (total number of items in array MINUS 1)
spawnQuantArrayNumber=$((${#jobArrayQuant[@]} -1))

#Start array of Sbatches.
sbatch --array=0-$spawnQuantArrayNumber -W /project/Path-Steen/ShellScripts/Sbatch_SpawnQuant.sh "${jobArrayQuant[@]}"

echo "Writing quantindex files is done. Will now start IonQuant quantification."

#######################
#
### IonQuant 
#
######################

#Run the Ionquant script. Once finished it will also clean the workspaces.

sbatch -W /project/Path-Steen/ShellScripts/Sbatch_IonQuant.sh

echo "Quantification done. All steps done. Fragpipe Finished."

#Note to self; maybe check the number of samples of input vs output.
#If they are not equal, see which samples are missing.












