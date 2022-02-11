#!/bin/bash

source /project/Path-Steen/ShellScripts/settings.sh

#set -xe

files=$1
filesDir=$2

#set up some prestrings.
prestring=' --psm ./'
poststring='/psm.tsv'
appendstring=''
abacusstring=''
space=" "

#make the big strings. There are input for abacus and IonQuant
for myFile in $outputdirectory/*/
do
	filename=$(basename $myFile)
	
	prefilenamepost=$prestring$filename$poststring

	appendstring="$appendstring$prefilenamepost"

	abacusstring="$abacusstring$filename$space"
done

cd $outputdirectory

#IonQuant Run
java -Xmx32G -jar $ionquantNetworkPath --threads 2 --ionmobility 1 --mbr 1 --multidir . --proteinquant 2 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0 --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1 --peptidefdr 1 --normalization 1 --minisotopes 2 --writeindex 1 --tp 3 --minfreq 0.5 --minions 1 --minexps 1 $appendstring --specdir $inputdirectory $files

