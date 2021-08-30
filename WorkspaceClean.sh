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

#cd to correct directory
cd /mnt/Path-Steen/analysis/workspace/

#Workspace clean in samples
for myFile in /mnt/Path-Steen/analysis/workspace/*/
do
	cd ./$(basename $myFile)
	
	$philosopherPath workspace --clean
	
	cd ../
done

$philosopherPath workspace --clean





