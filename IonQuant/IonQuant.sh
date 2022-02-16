#!/bin/bash
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source $1/settings/settings.sh

cd $outputdirectory/results/

#set up some prestrings.
prestring=' --psm '
poststring='/psm.tsv'
appendstring=''

#make the big string for IonQuant
for myFile in $inputdirectory/*.d
do
        filename=$outputdirectory/results/$(basename ${myFile::-2})
        prefilenamepost=$prestring$filename$poststring
        appendstring="$appendstring$prefilenamepost"
done

#IonQuant Run 
java -Xmx180G -jar $ionquantNetworkPath --threads 96 --ionmobility 1 --mbr 1\
 --multidir . --proteinquant 2 --requantify 1 --mztol 10 --imtol 0.05 --rttol 0.4\
  --mbrmincorr 0 --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 10 --ionfdr 0.01 --proteinfdr 1\
   --peptidefdr 1 --normalization 1 --minisotopes 2 --writeindex 0 --tp 3 --minfreq 0.5 --minions 1\
    --minexps 1 $appendstring --specdir $inputdirectory $(find $outputdirectory/results -name "*.pepXML")

# #Clean the workspaces
# for myFile in $outputdirectory/*/
# do
# 	cd ./$(basename $myFile)
	
# 	$philosopherNetworkPath workspace --clean
	
# 	cd ../
# done

# $philosopherNetworkPath workspace --clean
