#!/bin/bash

set -xe

# Specify paths of tools and files to be analyzed.
outputPath="/tmp/outputfiles/" ############## ALSO CHANGE AT THE filter step. 
fastaPath="/tmp/msfragger1/FASTA/2021-06-09-decoys-contam-IgOME_FASTAFILE_allExcept161Igomes_NoLeader.fasta.fas"
msfraggerPath="/tmp/msfragger2/MSFragger-20171106/MSFragger-3.1.1/MSFragger-3.1.1.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
fraggerParamsPath="/tmp/msfragger2/fragger.params"
philosopherPath="/tmp/msfragger2/tools/philosopher/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
ionquantPath="/tmp/msfragger2/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.5.5.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
decoyPrefix="rev_"

#Make directories for each of the .d files.
for myFile in /tmp/timstoffiles2/*.d
do
	mkdir /tmp/outputfiles2/$(basename ${myFile::-2})
	cd /tmp/outputfiles2/$(basename ${myFile::-2})
	$philosopherPath workspace --clean --nocheck
	$philosopherPath workspace --init --nocheck
	cd ../
done

$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --nocheck

#Next, we run MSFRAGGER. change xmx for the GB on your system
java -Xmx80G -jar $msfraggerPath $fraggerParamsPath /tmp/timstoffiles2/*.d

#Move the pepXML files to output directory
for myFile in /tmp/timstoffiles2/*.d
do 
	mv ${myFile::-2}.pepXML /tmp/outputfiles2/$(basename ${myFile::-2})
done

#Last thing we can run in parallel is PeptideProphet. From there on it cant be parallelized (I think)
$philosopherPath peptideprophet --decoyprobs --ppm --accmass --nonparam --expectscore --decoy $decoyPrefix --database $fastaPath $(find /tmp/outputfiles2/ -name "*.pepXML")




