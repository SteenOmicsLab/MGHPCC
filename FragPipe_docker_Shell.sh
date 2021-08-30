#!/bin/bash

set -xe

#chmod items
chmod 770 -R /mnt/Path-Steen/msfragger/
chmod u+x /mnt/Path-Steen/msfragger/tools/philosopher/philosopher

#Move to the correct directory
cd /mnt/Path-Steen/analysis/outputfiles/

# Specify paths of tools and files to be analyzed.
outputPath="/mnt/Path-Steen/analysis/outputfiles/" ############## ALSO CHANGE AT THE filter step.
dataDirPath="/mnt/Path-Steen/analysis/timstoffiles/"
fastaPath="/mnt/Path-Steen/msfragger/FASTA/2021-04-11-decoys-UP000005640_9606_SARS_COV_2.fasta.fas"
msfraggerPath="/mnt/Path-Steen/msfragger/MSFragger-20171106/MSFragger-3.1.1/MSFragger-3.1.1.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
fraggerParamsPath="/mnt/Path-Steen/msfragger/fragger.params"
philosopherPath="/mnt/Path-Steen/msfragger/tools/philosopher/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
ionquantPath="/mnt/Path-Steen/msfragger/MSFragger-20171106/MSFragger-3.1.1/IonQuant-1.5.5.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
decoyPrefix="rev_"


#Make experimental directories. Here we will store files for each .d file. These folders will be made in the CURRENT DIRECTORY!
for myFile in $dataDirPath*.d
do
mkdir -p  ./$(basename ${myFile::-2})
	cd ./$(basename ${myFile::-2})
	$philosopherPath workspace --clean --nocheck
	$philosopherPath workspace --init --nocheck
	cd ../
done

$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --nocheck

# Run MSFragger. Change the -Xmx value according to your computer's memory.
#java -jar -Dfile.encoding=UTF-8 -Xmx200G $msfraggerPath $fraggerParamsPath $dataDirPath/*.d
java -Xmx150G -jar $msfraggerPath $fraggerParamsPath $dataDirPath*.d

#Now we want to move the pepxml files from file directory, to output directory
#Next, we clean workspace, initiate workspace and run peptideprophet

#move pepxml files
for myFile in $dataDirPath*.d
do
	mv ${myFile::-2}.pepXML ./$(basename ${myFile::-2})
	cd ./$(basename ${myFile::-2})
	
	cd ../
done

#Run peptide prophet, followed by proteinprophet
$philosopherPath peptideprophet --decoyprobs --ppm --accmass --nonparam --expectscore --decoy $decoyPrefix --database $fastaPath $(find ./ -name "*.pepXML")
	
$philosopherPath proteinprophet --maxppmdiff 2000000 --output combined $(find ./ -name "*.pep.xml")

#Set up databases for of the samples
for myFile in $dataDirPath*.d
do
	cd ./$(basename ${myFile::-2})
	$philosopherPath database --annotate $fastaPath --prefix $decoyPrefix
	cd ../

done

#set up database for the combined
$philosopherPath database --annotate $fastaPath --prefix $decoyPrefix

#Filter for each of the samples
for myFile in $dataDirPath*.d
do
	cd ./$(basename ${myFile::-2})
	$philosopherPath filter --sequential --razor --prot 0.01 --tag $decoyPrefix --pepxml ./ --protxml /mnt/Path-Steen/analysis/outputfiles/combined.prot.xml 
	cd ../

done


#Write reports for each of the samples
for myFile in $dataDirPath*.d
do
	cd ./$(basename ${myFile::-2})
	$philosopherPath report
	cd ../

done

#Run iprophet. I follow a Fragpipe run here.
$philosopherPath iprophet --decoy rev_ --nonsp --output combined --threads 60 $(find ./ -name "*.pep.xml")

#set up some prestrings.
prestring=' --psm ./'
poststring='/psm.tsv'
appendstring=''
abacusstring=''
space=" "

#make the big strings. There are input for abacus and IonQuant
for myFile in $dataDirPath*.d
do
	filename=$(basename ${myFile::-2})
	
	prefilenamepost=$prestring$filename$poststring

	appendstring="$appendstring$prefilenamepost"

	abacusstring="$abacusstring$filename$space"
done

#run abacus
$philosopherPath abacus --razor --reprint --tag rev_ --protein --peptide $abacusstring

#ionQuant
java -Xmx200G -jar $ionquantPath --threads 40 --ionmobility 1 --mbr 1 --multidir . --proteinquant 2 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0 --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1 --peptidefdr 1 --normalization 1 --minisotopes 2 --writeindex 0 --tp 3 --minfreq 0.5 --minions 1 --minexps 1 $appendstring --specdir $dataDirPath $(find ./ -name "*.pepXML")

#Workspace clean in samples
for myFile in $dataDirPath*.d
do
	cd ./$(basename ${myFile::-2})
	
	$philosopherPath workspace --clean
	
	cd ../
done

#workspace clean combined
$philosopherPath workspace --clean

