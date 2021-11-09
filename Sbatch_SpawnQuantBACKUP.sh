#!/bin/bash

#SBATCH --partition=mghpcc-compute 	#Queue to be used?
#SBATCH --account=bch-mghpcc		#account name
#SBATCH --time=2:00:00 		#5 days which is the max?
#SBATCH --job-name=QuantWriter		#Job name
#SBATCH --mail-type=BEGIN,END,FAIL	
#SBATCH --mail-user=patrick.vanzalm@childrens.harvard.edu
#SBATCH --nodes=1 			#Number of Nodes needed
#SBATCH --cpus-per-task=2		#Number of CPUS needed
#SBATCH --mem=32GB			#Memory needed	
#SBATCH --output=/project/Path-Steen/logs/IonQuantWriter_%j.log #Name of the output file

#Load Singularity on the Node
module load singularity


files=$1
filesDir=$2

#SingularityCommand
commandSingularity="singularity exec --bind /project/:/project/ /project/Path-Steen/testy /project/Path-Steen/ShellScripts/QuantindexWriter.sh"

#Make an array with the singularity command and the inputs
CommandArray=($commandSingularity "$files" "$filesDir")

touch /tmp/log"$SLURM_JOBID".txt

#Run the command script and have it keep a log of the stdout. 
#if the "Updating Philosopher" string is found it means IonQuant is done writing .quantindex files.
#Until IonQuant has a seperate option to write .quantindex files, this is a temporary fix.
"${CommandArray[@]}" > /tmp/log"$SLURM_JOBID".txt &
until grep -q "Updating Philosopher" /tmp/log"$SLURM_JOBID".txt
do
        sleep 5
        echo "Not found...."
done

echo "All .quantindex writing has completed. Will kill script now."

#Remove the log file
rm /tmp/log"$SLURM_JOBID".txt

#kill process
kill $$



