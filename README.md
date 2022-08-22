<img align="right" src="Images/ScriptHPCFragpipe.png">

# Fragpipe Parallelization Aproach on High Performance Computing

## Introduction

The scripts in this github repository are used to run analysis of mass spectrometry proteomics data using the Fragpipe tools in a parallelized high-throughput manner. By combing the Fragpipe tools and the parallelization capabilities of a high performance computing (HPC) service we can achieve a 90% time reduction compared to the regular non-parallelized approach of timsTOF data. 

The whole processes is steered by the combined.sh - shell script. It will first briefly check the input parameters before it follows the order of MSFragger, Philosopher and Ionquant. More information on each of these sub-processes can be found in the respective directory.

## Tools and Environment

    HPC:
    - CentOS (7.9.2009)
    - OpenHPC (1.3)
    - Slurm 18.08.8
    - singularity 3.6.4
    - bash 4.2.46(2)

    Fragpipe:
    - MSFragger 3.4
    - Philosopher 4.1.1
    - IonQuant 1.7.17

NOTE: Fragpipe has its own unique licensing. We can therefore not offer this prepackaged inside a public container. User would have to do the following manually:
1. Download all Fragpipe tools, order them as specified in the /treeMSFragger directory
2. Copy this directory to users HPC

## Overview

User first once specifies settings in the settings.sh file. From there on user can start a search using the combined.sh script. More info on these two files can be found in combined_and_settings_info.md file. There is also more information on each subprocces in each of the subdirectories. 

## How - To Run

#### 1. Set up Fragpipe

Download Msfragger, fragpipe and IonQuant and follow the directory structure as shown in the tree. Copy to your HPC.

#### 2. Build the Singularity container

run:

    cd <YOUR_HPC_DIRECTORY>
    singularity build ubuntu_fragpipe docker://patrickvanzalm/ubuntu_fragpipe


#### 3. Get the scripts

Clone the scripts

    cd <YOUR_HPC_DIRECTORY>
    git clone https://github.com/PatrickvanZalm/MGHPCC.git


#### 4. Update HPC settings

Each HPC has its own names for account and partitions. Please adjust accordingly lines 2 and 3 in each of the following files:

    /2_MSFragger/Sbatch_write_mzBIN.sh
    /2_MSFragger/Sbatch_MSfragger.sh
    /3_Philosopher/Sbatch_peptideProphet.sh
    /3_Philosopher/Sbatch_proteinProphet.sh
    /4_IonQuant/Sbatch_write_quantindex.sh
    /4_IonQuant/Sbatch_IonQuant.sh


#### 5. Update settings.sh 

We need to specify once where scripts are located, Where fragpipe tools are, number of samples per batch and how often we want to split the database in MSFragger. 

#### 5. Specific Fragpipe settings

For MSFragger settings we suggest using Fragpipe on a local device to produce the fragger.params file and copy this to HPC.

Philosopher settings can be adjusted in the 3_Philosopher/peptideProphet.sh and 3_Philosopher/proteinProphet.sh files.

Quantification settings can be adjusted in 4_IonQuant/IonQuant.sh files.

NOTE: Code assumed that FASTA file already inclused decoys. If not one can use [Philosopher](https://github.com/Nesvilab/philosopher/wiki/How-to-Prepare-a-Protein-Database)

#### 7. Copy Bruker .d data to your HPC

Depending on your local HPC this will most likely be through SSH or a cloud-based storage, for which you could use [Rclone](https://rclone.org/)

#### 8. Run

All should be set up. The combined.sh script can take care of the whole data pipeline. The script required five inputs in the following order:

1. Input directory (where the Bruker .d's are located)
2. Output directory (Where all results, logs and settings are saved and used)
3. FASTA file
4. fragger.params file
5. Location of all the scripts as provided in this repository

 Starting it could look like the following:
 
    /your_repository/fragPipeScripts/combined.sh /your_repository/timstoffiles/ /your_repository/results/ /your_repository/FASTA/MyFASTAfile.fasta.fas /your_repository/fragger.params /your_repository/FragpipeScripts/


