#!/bin/bash
export LC_ALL=C

#specify the three inputs
sourcefile=$1
SLURM_JOBID=$2
SLURM_ARRAY_TASK=$3

#Grab settings, set fastafile path from settings.sh
source $1/settings/settings.sh

#Load the array that is written in the combined.sh script.
arr=()
while IFS= read -r line; do
   arr+=("$line")
done <$1/settings/write_MZbin.txt

# Echo so that in case goes wrong we can re-find
echo "${arr[$SLURM_ARRAY_TASK_ID]}"

# #Make tmp directories
mkdir -p /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
mkdir -p /tmp/timstoffiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/

#copy the batch bruker files.
cp -r ${arr[$SLURM_ARRAY_TASK_ID]} /tmp/timstoffiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/

#Copy Msfragger and fragger.params, give chmods
cp -r $fragpipeDirectory/* /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
cp $fraggerParamsNetworkPath /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod 777 -R /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
chmod u+x /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/tools/philosopher/philosopher

#copy the params file and adjust the variable within this script. We want to adjust it to write mzbin
fraggerParamsTempPath=/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/$(basename ${fraggerParamsNetworkPath})

#We make a temp FASTA file with the sequence of one protein (and its rev_ form)
echo ">sp|A0A024RBG1|NUD4B_HUMAN Diphosphoinositol polyphosphate phosphohydrolase NUDT4B OS=Homo sapiens OX=9606 GN=NUDT4B PE=3 SV=1" >> /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/testfasta.fasta
echo "MMKFKPNQTRTYDREGFKKRAACLCFRSEQEDEVLLVSSSRYPDQWIVPGGGMEPEEEPGGAAVREVYEEAGVKGKLGRLLGIFEQNQDRKHRTYVYVLTVTEILEDWEDSVNIGRKREWFKVEDAIKVLQCHKPVHAEYLEKLKLGCSPANGNSTVPSLPDNNALFVTAAQTSGLPSSVR" >> /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/testfasta.fasta
echo ">rev_sp|A0A024RBG1|NUD4B_HUMAN Diphosphoinositol polyphosphate phosphohydrolase NUDT4B OS=Homo sapiens OX=9606 GN=NUDT4B PE=3 SV=1" >> /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/testfasta.fasta
echo "RVSSPLGSTQAATVFLANNDPLSPVTSNGNAPSCGLKLKELYEAHVPKHCQLVKIADEVKFWERKRGINVSDEWDELIETVTLVYVYTRHKRDQNQEFIGLLRGLKGKVGAEEYVERVAAGGPEEEPEMGGGPVIWQDPYRSSSVLLVEDEQESRFCLCAARKKFGERDYTRTQNPKFKMM" >> /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/testfasta.fasta

#Alter the FASTA file location in the fragger.params file
databaseTemp="database_name = "
sed -i "1s|.*|$databaseTemp/tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/testfasta.fasta|" $fraggerParamsTempPath

#We also want to turn the calibration and optimization off. We try for =2 and =1 
sed -i 's/calibrate_mass = 2/calibrate_mass = 0/g' $fraggerParamsTempPath
sed -i 's/calibrate_mass = 1/calibrate_mass = 0/g' $fraggerParamsTempPath

cat $fraggerParamsTempPath

#Run MSFragger with the "one protein FASTA"
java -Xmx16G -jar $msfraggerPath $fraggerParamsTempPath /tmp/timstoffiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/*.d

#identify the number of mzBIN files
mzBINnumber=$(find /tmp/timstoffiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/*.mzBIN -type f | wc -l)

#if numberOfFilesPerBatch is not equal to number of mzBIN something went wrong and we throw error. Otherwise, the copy the mzBIN files over.
#If inputNumber and pepXMLNumber are not equal it means all went fine. If not, it should not copy, and echo print that something went wrong.
if (( $numberOfFilesPerBatch == $mzBINnumber))
then
	#Copy mzBIN and .mgf
	cp /tmp/timstoffiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/*.mzBIN $inputdirectory
	cp /tmp/timstoffiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/*.mgf $inputdirectory
   #Remove /tmp files
   rm -r /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
   rm -r /tmp/timstoffiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
   exit 0
else
	echo "Something did go wrong. The number of .pep.xml files did not correspond with the number of samples in this batch"
   #Remove /tmp files
   rm -r /tmp/fragpipe"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"/
   rm -r /tmp/timstoffiles"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID"
   exit 1
fi
