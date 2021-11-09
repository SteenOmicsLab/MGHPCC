#!/bin/bash

#SBATCH --partition=mghpcc-compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=1:00:00 		#5 days which is the max?
#SBATCH --job-name=QuantWriter		#Job name
#SBATCH --mail-type=BEGIN,END,FAIL	
#SBATCH --mail-user=patrick.vanzalm@childrens.harvard.edu
#SBATCH --nodes=1 			#Number of Nodes needed
#SBATCH --cpus-per-task=8		#Number of CPUS needed
#SBATCH --mem=16GB			#Memory needed	
#SBATCH --output=/project/Path-Steen/logs/IonQuantWriter_%A_%a.log #Name of the output file

#Load Singularity on the Node
module load singularity

#Import the array
arr=("$@")

echo "${arr[$SLURM_ARRAY_TASK_ID]}"

#SingularityCommand
commandSingularity="singularity exec --bind /project/:/project/ /project/Path-Steen/testy /project/Path-Steen/ShellScripts/QuantindexWriter.sh"

#Make an array with the singularity command and the inputs
CommandArray=($commandSingularity "${arr[$SLURM_ARRAY_TASK_ID]}" )

touch /tmp/log"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID".txt

#Run the command script and have it keep a log of the stdout. 
#if the "Updating Philosopher" string is found it means IonQuant is done writing .quantindex files.
#Until IonQuant has a seperate option to write .quantindex files, this is a temporary fix.
"${CommandArray[@]}" > /tmp/log"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID".txt &
until grep -q "Done!" /tmp/log"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID".txt #Updating Philosopher
do
        sleep 5
        echo "Not found...."
done

echo "All .quantindex writing has completed. Will kill script now."

cat /tmp/log"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID".txt

#Remove the log file
rm /tmp/log"$SLURM_JOBID""$SLURM_ARRAY_TASK_ID".txt

#kill process
kill $$
