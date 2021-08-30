#!/bin/bash

set -xe

# Specify paths of tools and files to be analyzed.
dataDirPath="/mnt/Path-Steen/analysis/timstoffiles/"
fastaPath="/mnt/Path-Steen/msfragger/FASTA/2021-04-11-decoys-UP000005640_9606_SARS_COV_2.fasta.fas"
msfraggerPath="/mnt/Path-Steen/msfragger/MSFragger-20171106/MSFragger-3.1.1/MSFragger-3.1.1.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
fraggerParamsPath="/mnt/Path-Steen/msfragger/fragger.params"
philosopherPath="/mnt/Path-Steen/msfragger/tools/philosopher/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
ionquantPath="/mnt/Path-Steen/msfragger/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.5.5.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
decoyPrefix="rev_"


cd /mnt/Path-Steen/analysis/workspace/

#Run iprophet. I follow a Fragpipe run here.
#$philosopherPath iprophet --decoy rev_ --nonsp --output combined --threads 48 $(find ./ -name "*.pep.xml")

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

echo $abacusstring

#run abacus
$philosopherPath abacus --razor --reprint --tag rev_ --protein --peptide $abacusstring

#Done. Only IonQuant left after this.
