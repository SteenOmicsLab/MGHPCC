# Info on the combined.sh and settings.sh files

## Settings.sh

File with settings that (usually) have to be set once:
1. Location of the containers
2. Location of Fragpipe tools
3. Location of the Fragpipe tools if they are copied over to a local node.
4. Decoy Prefix. Commonly _rev is used
5. number of files per batch. Depends on the storage space on computational nodes
6. dbsplits option for MSFragger

## combined.sh

This is the script that executes all other scripts. Please note the script has to continue running, even if user logs-off. We suggest using [screen](https://www.gnu.org/software/screen/).

The script will execute the following steps:

#### Test input

1. If there is no input directory specified, kill
2. If number of bruker files (*.d) is 0, kill
3. Make output directory, if not specified, kill
4. Check FASTA file extension (.fas or .fasta). If not correct, kill

#### Prepare for Run

1. Inside the specified results directory we make a logs, settings and results subdirectory. All Sbatch logs will go to logs.
2.  In the settings directory the scripts will be copied, as well as the fragger.params and FASTA file.
3. We append user specified settings to the settings.sh file.
4. We source these new settings.
5. We update the fragger.parmas file with the new FASTA location.
6. Just to be sure, we give execution rights to Fragpipe and philosopher tools.

#### Prepare batching

Make an array of all the input bruker files which will be used for batching later on.

We take the total of bruker files in the input directory and first test if that number is not smaller than the numberOfFilesPerBatch - variable in the settings.sh file. Next, we Divide total number of samples by the numberOfFilesPerBatch variable. We also calculate the modulo because the last batch in the array will include this modulo. We therefore round the number of batches down in the numberFilesNoModulo variable.

We declare an empty array (jobArray) and run a forloop over a sequence from 0 to numberFilesNoModulo, with an increment of numberOfFilesPerBatch.

Inside the loop: if not the last batch take numberOfFilesPerBatch and put in the declared jobArray. Repeat until all but the last batch if added to this array. For the last one we add all PLUS the modulo.

Finally, we loop over this array and write the array to the outputdirectory/settings/write_mzBIN.txt file, which will be used throughout for the batching.

#### WRITE mzBIN

1. Determine the number of SLURM array numbers that has to be run.
2. Determine number of mzBIN files in inputdirectory
3. If number of files and number of mzBIN files not equal, start writing the mzBIN files using sbatch, where we split based on the developed array.

#### MSFragger

Start the MSFragger Sbatch_MSFragger.sh script.

#### peptideProphet

We use the same mzBIN array here and split it up exactly the same for running peptideProphet.

#### ProteinProphet

Start the ProteinPropet Sbatch_proteinProphet.sh script

#### write quantindex

We use the same mzBIN array here and split it up exactly the same for writing the quantindex files.

#### IonQuant

Start the ProteinPropet Sbatch_IonQuant.sh script



