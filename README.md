<img align="right" src="Images/ScriptHPCFragpipe.png">

# Fragpipe Scripts on High Performance Computing

To facilitate speedy processing of large-scale proteomic studies we utilize High Performance Computing (HPC) and fragpipe. MSFragger 3.4, Philosopher 4.1.1 and IonQuant 1.7.17 were used and tested. On the HPC we have CentOS (7.9.2009) with OpenHPC (1.3), Slurm 18.08.8, singularity 3.6.4 and bash 4.2.46(2). A docker container was build with Ubuntu 20.04 with the dependencies as shown in the Dockerfile. The Docker container was transformed to a singularity container.

due to licensing of Fragpipe software we decided to keep all the required Fragpipe software out of the container. A schematic of the directory with all the data can be found in the treeMsfragger sub-directory. Do note that IonQuant has to be in the same subdirectory as MSFragger is. All software is called into the container by binding the directories.

The combined.sh script imitates the whole Fragpipe workflow with timsTOF data and for LFQ quantification where each input file is a single sample/experiment.

# How - To 

#### 1. Set up Fragpipe

Download Msfragger, fragpipe and IonQuant and follow the directory structure as shown in the tree. Copy to your HPC.

#### 2. Build the Singularity container

run:

    singularity build ubuntu_fragpipe docker://patrickvanzalm/ubuntu_fragpipe


#### 3. Make Logs and Scripts directory, download scripts

We want to make a directory for the scripts, and one for the logs. For example:

    mkdir FragpipeScripts
    cd FragpipeScripts
    git clone https://github.com/PatrickvanZalm/MGHPCC.git
    cd ../


#### 4. Update Sbatch commands

In the directory where the scripts are cloned we have to do some manual updating:

1. The Sbatch_*.sh SLURM parameters, which will depend on your local HPC.
2. the settings.sh file where you specify locations of Fragpipe directories and executables, location of Singularity container and prefix.

#### 5. 

Specify settings in the fragger.params file (for MSFragger) or more specific settings in the scripts if one would want to.

#### 6. Copy Bruker .d data to your HPC

Depending on your local HPC this will most likely be through SSH or a cloud-based storage, for which you could use [Rclone](https://rclone.org/)

#### 7. Run

All should be set up. The combined.sh script can take care of the whole data pipeline. The script required four inputs in the following order:

1. Input directory (where the Bruker .d's are located)
2. Output directory (Where all results, logs and settings are saved and used)
3. FASTA file
4. fragger.params file
5. Location of all the scripts as provided in this repository

 Starting it could look like the following:

    /your_repository/fragPipeScripts/combined.sh /your_repository/timstoffiles/ /your_repository/results/ 30 /your_repository/FASTA/yourFASTA.fasta.fas
    /your_repository/fragPipeScripts/combined.sh /your_repository/timstoffiles/ /your_repository/results/ /your_repository/FASTA/MyFASTAfile.fasta.fas /your_repository/fragger.params /your_repository/FragpipeScripts/

NOTE: Code assumed that FASTA file already inclused decoys. If not one can use [Philosopher](https://github.com/Nesvilab/philosopher/wiki/How-to-Prepare-a-Protein-Database)

