#!/bin/bash

#Have to set the LC_ALL. Not really sure why?
export LC_ALL=C

source /project/Path-Steen/MGHPCC/settings.sh

#make msfragger directory, Copy Msfragger, give chmods
mkdir -p /tmp/msfragger"$SLURM_JOBID"/
cp -r /project/Path-Steen/msfragger/* /tmp/msfragger"$SLURM_JOBID"/
chmod 770 -R /tmp/msfragger"$SLURM_JOBID"/
chmod u+x /tmp/msfragger"$SLURM_JOBID"/tools/philosopher/philosopher

# TO RUN THIS ONE NEEDS A DIRECTORY WITH JUST ALL THE .pepxml and pep.xml files in it! It is not in seperate subfolders, like we do for the other pipeline.

#Go to the output directory, same as in the MSFragger script
cd $outputdirectory

#Run philosopher workspace to set up.
$philosopherNonArrayPath workspace --clean --nocheck
$philosopherNonArrayPath workspace --init --nocheck
$philosopherNonArrayPath database --annotate $fastaFile --prefix $decoyPrefix

#Run ProteinProphet	
#$philosopherNonArrayPath proteinprophet --maxppmdiff 2000000 --output combined $(find ./ -name "*.pep.xml")

$philosopherNonArrayPath workspace --clean --nocheck
$philosopherNonArrayPath workspace --init --nocheck
$philosopherNonArrayPath database --annotate $fastaFile --prefix $decoyPrefix

$philosopherNetworkPath filter --sequential --razor --prot 0.01 --tag $decoyPrefix --pepxml ./ --protxml $outputdirectory/combined.prot.xml

$philosopherNonArrayPath report

#Delete the directories
rm -r /tmp/msfragger"$SLURM_JOBID"/
