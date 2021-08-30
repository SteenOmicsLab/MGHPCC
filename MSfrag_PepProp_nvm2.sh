#!/bin/bash

set -xe

#Make subdirectories on temporary folder. We CD to outputfiles too to save.
mkdir -p /tmp/outputfiles2/
mkdir -p /tmp/timstoffiles2/
cd /tmp/outputfiles2/

#Save the file as a variable
file=$1

#Move the required files there. We do ONE .d and all Fragpipe related stuff
cp -r  $1 /tmp/timstoffiles2/
#cp -R /mnt/Path-Steen/msfragger/ /tmp/

#chmod items
chmod 770 -R /tmp/msfragger/
chmod u+x /tmp/msfragger/tools/philosopher/philosopher

# Specify paths of tools and files to be analyzed.
outputPath="/tmp/outputfiles2/" ############## ALSO CHANGE AT THE filter step. 
fastaPath="/tmp/msfragger/FASTA/2021-04-11-decoys-UP000005640_9606_SARS_COV_2.fasta.fas"
msfraggerPath="/tmp/msfragger/MSFragger-20171106/MSFragger-3.1.1/MSFragger-3.1.1.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
fraggerParamsPath="/tmp/msfragger/fragger.params"
philosopherPath="/tmp/msfragger/tools/philosopher/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
ionquantPath="/tmp/msfragger/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.5.5.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
decoyPrefix="rev_"

#make a directory of the file as inputted in the shell script
#Next, we cd into it to do a workspace clean and init command
mkdir -p /tmp/outputfiles2/$(basename ${file::-2})
cd /tmp/outputfiles2/ # $(basename ${file::-2})
$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --nocheck
#cd /dev/shm/outputfiles/$(basename ${file::-2})

#Next, we run MSFRAGGER. change xmx for the GB on your system
java -Xmx90G -jar $msfraggerPath $fraggerParamsPath /tmp/timstoffiles2/*.d

#Now we want to move the pepxml files from file directory, to output directory
mv /tmp/timstoffiles2/$(basename ${file::-2}).pepXML /tmp/outputfiles2/$(basename ${file::-2})

#move to the directory, there we will create workspace with Philosopher
#cd /dev/shm/outputfiles/$(basename ${file::-2})
#$philosopher workspace --clean --nocheck
#$philosopher workspace --init --nocheck

#Last thing we can run in parallel is PeptideProphet. From there on it cant be parallelized (I think)
$philosopherPath peptideprophet --decoyprobs --ppm --accmass --nonparam --expectscore --decoy $decoyPrefix --database $fastaPath $(find /dev/shm/outputfiles2/ -name "*.pepXML")

#Copy the results to mnt folder
cp -r /tmp/outputfiles2/$(basename ${file::-2}) /mnt/Path-Steen/analysis/outputfiles/

#Remove files from /dev/shm/
rm -r /tmp/msfragger/
rm -r /tmp/timstoffiles2/
rm -r /tmp/outputfiles2/

exit

