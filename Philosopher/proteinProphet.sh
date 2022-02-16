#!/bin/bash
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source $1/settings/settings.sh

#Go to right directory, set up DB, run proteinprophet
cd $outputdirectory/results
$philosopherNetworkPath database --annotate $fastaFile --prefix $decoyPrefix
$philosopherNetworkPath proteinprophet --maxppmdiff 2000000 --output combined $(find $outputdirectory/results -name "*.pep.xml")

#Set up databases, run filter, make reports for each sample.
for myFile in $outputdirectory/results/*/
do
	echo $(basename $myFile)
	cd $outputdirectory/results/$(basename $myFile)
	$philosopherNetworkPath database --annotate $fastaFile --prefix $decoyPrefix
	$philosopherNetworkPath filter --sequential --razor --prot 0.01 --tag $decoyPrefix --pepxml ./ --protxml $outputdirectory/results/combined.prot.xml
	$philosopherNetworkPath report
	cd ../
done

#If all went well report will build a psm.tsv file for each inputfile. We use that to check if all ran fine.
numpepXML=$(find $inputdirectory/ -maxdepth 1 -name "*.pepXML" | wc -l)
numbpsm=$(find $inputdirectory/ -maxdepth 2 -name "psm.tsv" | wc -l) #Do note maxdepth 2 because there is also one in the .meta folder

#If inputNumber and pepXMLNumber are not equal it means all went fine. If not, it should not copy, and echo print that something went wrong.
if (( $numbpsm == $numpepXML))
then
	echo "script finished succesfully."
	exit 0
else
	echo "Something did go wrong. not same number"
	exit 1
fi

