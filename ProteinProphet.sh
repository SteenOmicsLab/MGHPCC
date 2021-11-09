#!/bin/bash
source /project/Path-Steen/ShellScripts/settings.sh

#make msfragger directory, Copy Msfragger, give chmods
mkdir -p /tmp/msfragger"$SLURM_JOBID"/
cp -r /project/Path-Steen/msfragger/* /tmp/msfragger"$SLURM_JOBID"/
chmod 770 -R /tmp/msfragger"$SLURM_JOBID"/
chmod u+x /tmp/msfragger"$SLURM_JOBID"/tools/philosopher/philosopher


#Go to the output directory, same as in the MSFragger script
cd $outputdirectory

#Run philosopher workspace to set up.
#$philosopherNonArrayPath workspace --clean --nocheck
#$philosopherNonArrayPath workspace --init --nocheck
#$philosopherNonArrayPath database --annotate $fastaFile --prefix $decoyPrefix

#Run ProteinProphet	
#$philosopherNonArrayPath proteinprophet --maxppmdiff 2000000 --output combined $(find ./ -name "*.pep.xml")

#Set up databases for each of the samples
for myFile in $outputdirectory/*/
do
	cd $(basename $myFile)
	$philosopherNonArrayPath workspace --clean --nocheck
	$philosopherNonArrayPath workspace --init --nocheck
	$philosopherNonArrayPath database --annotate $fastaFile --prefix $decoyPrefix
	cd ../
done

#cd back to output directory
cd $outputdirectory

#Filter for each of the samples
for myFile in $outputdirectory/*/
do
	cd $(basename $myFile)
#	$philosopherNonArrayPath filter --sequential --razor --prot 0.01 --tag $decoyPrefix --pepxml ./ --protxml $outputdirectory/combined.prot.xml
	cd ../
done

cd $outputdirectory

#Write reports for each of the samples
for myFile in $outputdirectory/*/
do
	cd $(basename $myFile)
#	$philosopherNonArrayPath report
	cd ../
done

cd $outputdirectory

#Run iprophet. I follow a Fragpipe run here. Used 48 threads before. Upping it here
#$philosopherNonArrayPath iprophet --decoy rev_ --nonsp --output combined --threads 96 $(find ./ -name "*.pep.xml")

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

echo $abacusstring

#run abacus
#$philosopherNonArrayPath abacus --razor --reprint --tag rev_ --protein --peptide $abacusstring
#$philosopherNonArrayPath abacus --razor --reprint --tag rev_ --protein $abacusstring  
#$philosopherNetworkPath abacus --razor --reprint --tag rev_ --protein $abacusstring

#Delete the directories
rm -r /tmp/msfragger"$SLURM_JOBID"/
