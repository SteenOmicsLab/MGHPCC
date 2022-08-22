#!/bin/bash
export LC_ALL=C

#Grab settings, set fastafile path from settings.sh
source $1/settings/settings.sh

#Go to right directory and run iProphet
cd $outputdirectory/results
$philosopherNetworkPath iprophet --decoy rev_ --nonsp --output combined --threads 96 $(find $outputdirectory/results -name "*.pep.xml")

# #If inputNumber and pepXMLNumber are not equal it means all went fine. If not, it should not copy, and echo print that something went wrong.
if test -f "$outputdirectory/results/combined.pep.xml"
then
	echo "script finished succesfully."
	exit 0
else
	echo "Something did go wrong. combined.pep.xml not found"
	exit 1
fi

