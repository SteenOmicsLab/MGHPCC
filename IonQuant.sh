#!/bin/bash

source /project/Path-Steen/ShellScripts/settings.sh

#set up some prestrings.
prestring=' --psm ./'
poststring='/psm.tsv'
appendstring=''
abacusstring=''
space=" "

cd $outputdirectory

#make the big strings. There are input for abacus and IonQuant
for myFile in $outputdirectory/*/
do
        filename=$(basename $myFile)

        prefilenamepost=$prestring$filename$poststring

        appendstring="$appendstring$prefilenamepost"

        abacusstring="$abacusstring$filename$space"
done

#IonQuant Run 
java -Xmx360G -jar $ionquantNetworkPath --threads 192 --ionmobility 1 --mbr 1 --multidir . --proteinquant 2 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0 --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1 --peptidefdr 1 --normalization 1 --minisotopes 2 --writeindex 0 --tp 3 --minfreq 0.5 --minions 1 --minexps 1 $appendstring --specdir $inputdirectory $(find ./ -name "*.pepXML")

#Clean the workspaces
for myFile in $outputdirectory/*/
do
	cd ./$(basename $myFile)
	
	$philosopherNetworkPath workspace --clean
	
	cd ../
done

$philosopherNetworkPath workspace --clean
