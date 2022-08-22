#!/bin/bash
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source $1/settings/settings.sh

#Go to right directory, set up DB, run proteinprophet
cd $outputdirectory/results
$philosopherNetworkPath database --annotate $fastaFile --prefix $decoyPrefix
$philosopherNetworkPath proteinprophet --maxppmdiff 2000000 --output combined $(find $outputdirectory/results -name "*.pep.xml")

#Move all files back and delete Dir. Could be done easier.
for myFile in $outputdirectory/results/*/
do
	echo $(basename $myFile)
	cd $outputdirectory/results/$(basename $myFile)
	mv ./* $outputdirectory/results/
	$philosopherNetworkPath workspace --clean
	cd ../
	rmdir $outputdirectory/results/$(basename $myFile)
done


#DB, Filter, Report.
$philosopherNetworkPath database --annotate $fastaFile --prefix $decoyPrefix
$philosopherNetworkPath filter --sequential --razor --prot 0.01 --tag $decoyPrefix --pepxml ./ --protxml $outputdirectory/results/combined.prot.xml
$philosopherNetworkPath report

