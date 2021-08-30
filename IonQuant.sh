#!/bin/bash

set -xe

# Specify paths of tools and files to be analyzed.
dataDirPath="/mnt/Path-Steen/analysis/timstoffiles/"
fastaPath="/mnt/Path-Steen/msfragger/FASTA/2021-04-11-decoys-UP000005640_9606_SARS_COV_2.fasta.fas"
msfraggerPath="/mnt/Path-Steen/msfragger/MSFragger-20171106/MSFragger-3.1.1/MSFragger-3.1.1.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
fraggerParamsPath="/mnt/Path-Steen/msfragger/fragger.params"
philosopherPath="/mnt/Path-Steen/msfragger/tools/philosopher/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
ionquantPath="/mnt/Path-Steen/msfragger/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.7.2-jar-with-dependencies.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
decoyPrefix="rev_"

#cd to correct directory
cd /mnt/Path-Steen/analysis/workspace/

#set up some prestrings.
prestring=' --psm ./'
poststring='/psm.tsv'
appendstring=''
abacusstring=''
space=" "

#make the big strings. There are input for abacus and IonQuant
for myFile in /mnt/Path-Steen/analysis/workspace/*/ 
do
	filename=$(basename $myFile)
	
	prefilenamepost=$prestring$filename$poststring

	appendstring="$appendstring$prefilenamepost"

	abacusstring="$abacusstring$filename$space"
done



#IonQuant Run 
java -Xmx330G -jar $ionquantPath --threads 192 --ionmobility 1 --mbr 1 --multidir . --proteinquant 2 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0 --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1 --peptidefdr 1 --normalization 1 --minisotopes 2 --writeindex 0 --tp 3 --minfreq 0.5 --minions 1 --minexps 1 $appendstring --specdir $dataDirPath $(find ./ -name "*.pepXML")

#Workspace clean in samples
#for myFile in /tmp/outputfiles//workspace/*/
#do
#	cd ./$(basename $myFile)
#	
#	$philosopherPath workspace --clean
#	
#	cd ../
#done

echo "Still gotta to the clean of workspaces"
#workspace clean combined
#$philosopherPath workspace --clean





