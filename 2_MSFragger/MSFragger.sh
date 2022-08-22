#!/bin/bash
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source $1/settings/settings.sh

#Make workspace for each of the .d files in the specified outputdirectory
for myFile in $inputdirectory/*.d
do
	mkdir -p $outputdirectory/results/$(basename ${myFile::-2})
	cd $outputdirectory/results/$(basename ${myFile::-2})
	$philosopherNetworkPath workspace --clean --nocheck
	$philosopherNetworkPath workspace --init --nocheck
done

#Make workspace in overal results directory
cd $outputdirectory/results/
$philosopherNetworkPath workspace --clean --nocheck
$philosopherNetworkPath workspace --init --nocheck

#Next, we run MSFRAGGER. change xmx for the GB on your system
#java -Xmx170G -jar $msfraggerNetworkPath $fraggerParamsNetworkPath $inputdirectory/*.d
echo $dbsplits
python3 $msfragDBsplitNetworkPath $dbsplits "java -Xmx360G -jar" $msfraggerNetworkPath $fraggerParamsNetworkPath $inputdirectory/*.d

#Check if number of pepXML files is same as input files. If yes, we copy over and exit 0. Otherwise exit 1
#Grab number of input directories, of .pepXML and of .pep.xml files
numbruker=$(find $inputdirectory/ -maxdepth 1 -name "*.d" | wc -l)
numpepXML=$(find $inputdirectory/ -maxdepth 1 -name "*.pepXML" | wc -l)

#If inputNumber and pepXMLNumber are not equal it means all went fine. If not, it should not copy, and echo print that something went wrong.
if (( $numbruker == $numpepXML))
then
	#Move the pepXML files to output directory
	for myFile in  $inputdirectory/*.d
	do 
		mv ${myFile::-2}.pepXML $outputdirectory/results/$(basename ${myFile::-2})
	done
	echo "MSFragger did finish succesfully."
	find /tmp/ -empty -type d -delete #remove the /tmp directories that philosopher workspace seems to make
	exit 0
else
	echo "Something did go wrong. The number of .pepXML files did not correspond with the number of samples in this batch"
	find /tmp/ -empty -type d -delete #remove the /tmp directories that philosopher workspace seems to make
	exit 1
fi
