#!/bin/bash
#SBATCH --partition=mghpcc-short #compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=1:00:00 		#12 hours. Normal search (i.e. tryptic, Oxidation and acetylation) will take +- 2 hours with 30 input files...
#SBATCH --job-name=EasypqpC 		#Job name
#SBATCH --nodes=1			#Number of Nodes needed
#SBATCH --cpus-per-task=1		#Number of CPUS needed
#SBATCH --mem=2GB			#Memory needed	

export LC_ALL=C

#source the settings and mzBIN arrays
source $1/settings/settings.sh

#Load Singularity on the Node
module load singularity

#Load the array that is written in the combined.sh script.
arr=()
while IFS= read -r line; do
   arr+=("$line")
done <$1/settings/write_MZbin.txt

echo "${arr[$SLURM_ARRAY_TASK_ID]}"

for resultsfile in ${arr[$SLURM_ARRAY_TASK_ID]} ;
do
    echo $resultsfile
	filename=$(basename ${resultsfile::-2})
	echo $filename
	singularity exec --bind /project/:/project/ $easypqpContainer easypqp convert --max_delta_unimod 0.02 --max_delta_ppm 15.0 --fragment_types '['"'"'b'"'"','"'"'y'"'"',]' --enable_unannotated --pepxml $outputdirectory/results/interact-"$filename".pep.xml --spectra $inputdirectory/"$filename"_uncalibrated.mgf --exclude-range -1.5,3.5 --psms $outputdirectory/results/"$filename".psmpkl --peaks $outputdirectory/results/"$filename".peakpkl
done

#Run job
# singularity exec --bind $inputdirectory,$outputdirectory,$fragpipeDirectory $container $1/settings/Philosopher/peptideProphet.sh "$1" "$SLURM_JOBID" "$SLURM_ARRAY_TASK_ID"
# singularity exec --bind /project/:/project/ $easypqpContainer easypqp convert --max_delta_unimod 0.02 --max_delta_ppm 15.0 --fragment_types '['"'"'b'"'"','"'"'y'"'"',]' --enable_unannotated --pepxml $outputdirectory/results/interact-"$filename".pep.xml --spectra $inputdirectory/"$filename"_uncalibrated.mgf --exclude-range -1.5,3.5 --psms $outputdirectory/results/"$filename".psmpkl --peaks $outputdirectory/results/"$filename".peakpkl
