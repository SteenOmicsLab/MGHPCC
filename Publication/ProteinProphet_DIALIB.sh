#!/bin/bash

#Have to set the LC_ALL. Not really sure why?
export LC_ALL=C

source /project/Path-Steen/MGHPCC/settings.sh
outputdirectory=/project/Path-Steen//results/IMPACC_Phase123_SpecLib/


#make msfragger directory, Copy Msfragger, give chmods
# mkdir -p /tmp/msfragger"$SLURM_JOBID"/
# cp -r /project/Path-Steen/msfragger/* /tmp/msfragger"$SLURM_JOBID"/
# chmod 770 -R /tmp/msfragger"$SLURM_JOBID"/
# chmod u+x /tmp/msfragger"$SLURM_JOBID"/tools/philosopher/philosopher

# TO RUN THIS ONE NEEDS A DIRECTORY WITH JUST ALL THE .pepxml and pep.xml files in it! It is not in seperate subfolders, like we do for the other pipeline.

#Go to the output directory, same as in the MSFragger script
cd $outputdirectory

#Run ProteinProphet	
#$philosopherNonArrayPath proteinprophet --maxppmdiff 2000000 --output combined $(find ./ -name "*.pep.xml")

philosopher workspace --clean --nocheck
philosopher workspace --init --nocheck
philosopher database --annotate $fastaFile --prefix $decoyPrefix

#$philosopherNetworkPath filter --sequential --razor --prot 0.01 --tag $decoyPrefix --pepxml ./ --protxml $outputdirectory/combined.prot.xml
philosopher filter --sequential --razor --prot 0.01 --tag $decoyPrefix --pepxml ./ --protxml $outputdirectory/combined.prot.xml

philosopher report

#Delete the directories
# rm -r /tmp/msfragger"$SLURM_JOBID"/
