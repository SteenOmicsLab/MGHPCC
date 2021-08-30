#!/bin/bash

set -xe

#Make subdirectories on temporary folder. We CD to outputfiles too to save.
mkdir -p /dev/shm/outputfiles/
mkdir -p /dev/shm/timstoffiles/
cd /dev/shm/outputfiles/

#Save the file as a variable
file=$1

#Move the required files there. We do ONE .d and all Fragpipe related stuff
cp -r  $1 /dev/shm/timstoffiles/
cp -R /mnt/Path-Steen/msfragger/ /dev/shm/

#chmod items
chmod 770 -R /dev/shm/msfragger/
chmod u+x /dev/shm/msfragger/tools/philosopher/philosopher

# Specify paths of tools and files to be analyzed.
outputPath="/dev/shm/outputfiles/" ############## ALSO CHANGE AT THE filter step. 
fastaPath="/dev/shm/msfragger/FASTA/2021-04-11-decoys-UP000005640_9606_SARS_COV_2.fasta.fas"
msfraggerPath="/dev/shm/msfragger/MSFragger-20171106/MSFragger-3.1.1/MSFragger-3.1.1.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
fraggerParamsPath="/dev/shm/msfragger/fragger.params"
philosopherPath="/dev/shm/msfragger/tools/philosopher/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
ionquantPath="/dev/shmn/msfragger/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.5.5.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
decoyPrefix="rev_"

#make a directory of the file as inputted in the shell script
#Next, we cd into it to do a workspace clean and init command
mkdir -p /dev/shm/outputfiles/$(basename ${file::-2})
cd /dev/shm/outputfiles/ # $(basename ${file::-2})
$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --nocheck
#cd /dev/shm/outputfiles/$(basename ${file::-2})

#Next, we run MSFRAGGER. change xmx for the GB on your system
java -Xmx120G -jar $msfraggerPath $fraggerParamsPath /dev/shm/timstoffiles/*.d

#Now we want to move the pepxml files from file directory, to output directory
mv /dev/shm/timstoffiles/$(basename ${file::-2}).pepXML /dev/shm/outputfiles/$(basename ${file::-2})

#move to the directory, there we will create workspace with Philosopher
#cd /dev/shm/outputfiles/$(basename ${file::-2})
#$philosopher workspace --clean --nocheck
#$philosopher workspace --init --nocheck

#Last thing we can run in parallel is PeptideProphet. From there on it cant be parallelized (I think)
$philosopherPath peptideprophet --decoyprobs --ppm --accmass --nonparam --expectscore --decoy $decoyPrefix --database $fastaPath $(find /dev/shm/outputfiles/ -name "*.pepXML")

#Copy the results to mnt folder
cp -r /dev/shm/outputfiles/$(basename ${file::-2}) /mnt/Path-Steen/analysis/outputfiles/

#Remove files from /dev/shm/
rm -r /dev/shm/msfragger/
rm -r /dev/shm/timstoffiles/
rm -r /dev/shm/outputfiles/

exit

