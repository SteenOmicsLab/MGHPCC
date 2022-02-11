# Index
1. Introduction
2. FragPipe
3. Container
4. FASTA
5. MSFragger + PeptideProphet
6. ProteinProphet + Philosopher
7. Write .quantindex
8. IonQuant
9. Example / Instructions

# 1. Introduction

The IMPACC study (DOI: 10.1126/sciimmunol.abf3733) is a prospective longitdinal study designed to enroll 1000 hospitalized patients, including the collection of blood specimen throughout the year. The Steen Lab at Boston Children's Hospital will be responsible for the proteomics analysis of those blood specimen. We expect to analye up to 10000 samples, which will result in an unprecedented amount of raw mass spectrometry data to analyse. FragPipe is known for its excellent speed and results with Bruker TimsTOF data (DOI: 10.1074/mcp.TIR120.002048), but analysis of such large quantities of samples is not feasible on a local computer. Instead, we have worked on implementing the FragPipe tools for High Performance Computing usage.

All processes were run on the [Massachusetts Green High Performance Computing Center](https://www.mghpcc.org/). MGHPCC is running CentOS (7.9.2009) with OpenHPC (1.3), Slurm 18.08.8, singularity 3.6.4 and bash 4.2.46(2). The script in this repository has been tested using msfragger 3.1.1., Philosopher 3.3.11. and IonQuant 1.7.2.

# 2. FragPipe

The FragPipe software is a licensed, java based computational tool for the analysis of mass spectrometry based proteomics data. To run all processes of the Fragpipe toolkit one has to download [FragPipe](https://github.com/Nesvilab/FragPipe/releases), [MSFragger](http://msfragger-upgrader.nesvilab.org/upgrader/) and [Philosopher](https://github.com/nesvilab/philosopher/releases/). 

We suggest to download these and try to make the directory have the same strucutre as ours before moving it over to your HPC. See below a low-level schematic of our directory. A detailed schematic (tree) can be found [here.](https://github.com/PatrickvanZalm/MGHPCC/tree/master/treeMsfragger)

    fragpipe/
    |-- FASTA
    |-- MSFragger-20171106
    |-- Philosopher
    |-- bin
    |-- cache
    |-- fragger.params
    |-- jre
    |-- lib
    |-- tools
    |-- updates
    `-- workflows


# 3. Container

Running Fragpipe requires a containerized operating system, for which we use Ubuntu (20.04), java (jdk 8) and some other dependencies (see DockerFile). The container can be found on [DockerHub](https://hub.docker.com/repository/docker/patrickvanzalm/ubuntu_fragpipe)

# 4. FASTA file

MSFragger expects a fasta file with decoys using the "rev_" prefix. If you have a fasta file without decoys please use philosopher as described [here.](https://github.com/Nesvilab/philosopher/wiki/How-to-Prepare-a-Protein-Database)

If you do have a fasta file with decoys but with a different prefix, it can be changed in the msfragger.sh script, line @@@@@@.

# 5. MSfragger + PeptideProphet

![alt text](Images/fraggerpeptideprophet.png "Title")

For each input file (.d directory) the MSfragger and PeptideProphet processes will result in an .pepXML and .pep.xml file, respectively. The creation these files does not require any interaction between input samples, and thus could be parallelized. To do so, the user has to give the following information to the script:
1. Location of the .d Bruker Files
2. Location of the output directory
3. Number of files per batch (we suggest to use a minimum of 20*)


Based on the user input the XXXX.sh script will determine the number of .d files in the directory and start multiple batches based on the user input, with the last batch always including the modulo. For each batch it will run the Sbatch_MSfragger.sh script, which includes SLURM specifics, as well as loading and starting the singularity container. The container (Ubuntu XXX) will execute the following steps:
1. Make directories (msfragger, timstoffiles, outputfiles).
2. Copy msfragger from network to node.
3. Copy .d files to node **
4. Make sub-directories and set up the philosopher workspace for each .d file in the outputfiles directory
5. Run the MSfragger java process to create .pepXML files
6. Copy the .pepXML files from the timstoffiles directory to the outputfiles directory
7. Run PeptideProphet to create .pep.xml files
8. Check if equal number of .pep.xml and samples are found and if yes, copy outputfiles from Node to network storage.
9. Clean up the Node.

*We noticed that if only a few bruker files are processed it might alter the fragment index width between batches. In our experience, batches of at least 20 will always lead to fragment indices of XX and XX, respectivly.

**We noticed that if we do not copy the .d files to the node's local storage the speed was vastly reduced. During the loading of the .d file (i.e. writing the .mzBIN file) we observed a high number of read/write processes. Having the .d files locally on the Node compared to over the network vastly improved the speed. Please contact your HPC administrator if this is possible. 

# 6. ProteinProphet + Philosopher

![alt text](Images/ProteinProphet.png "Title")

This script will run the following processes:
1. Set up database in outputfiles directory
2. Run proteinprophet for statistical validation of protein identifications
3. Set up databases in each of the samples
4. Filter each of the samples
5. Write reports for each of the samples
6. Run iProphet for multi-level integration analysis
7. Run Abacus to aggregate the data 

# 7. Write .quantindex

IonQuants speed is based on the (large) .quantindex files it writes for easy indexing. Similairy like MSfragger it uses the Bruker extension which currently only works single threaded. If .quantindex files are already written, IonQuant will skip the step which could potentially vastly improve speed. To parallelize the writing of quantindex files we build smaller batches and have multiple instances of IonQuant run simultaniously. Once all .quantindex files are written the IonQuant processes will be terminated.

In short, the script does the following:
1. Write the input parameter required for IonQuant. IonQuant requires a "--psm SAMPLE/psm.tsv" for each sample.
2. Run IonQuant, have the --writeindex parameter to true (1)
3. Once IonQuant pushes the "Updating Philosopher" string to stdout kill the process.

# 8. IonQuant

With the .quantindex files available we can now fully quantify the data. As described above the script will first build all the --psm variables, followed by running the IonQuant. Notice that --writeindex is set to False (0) here. Once quantification finished it means searching the data has completed. To reduce data storage we also clean the workspaces. We do this for the output directory, as well as within each sample directory.

# 9. Example / Instructions 

#### 1. Set up Fragpipe

Download Msfragger, fragpipe and IonQuant and follow the directory structure as shown in the tree. Copy to your HPC.

#### 2. Build the Singularity container

run:

    singularity build ubuntu_fragpipe docker://patrickvanzalm/ubuntu_fragpipe


#### 3. Make Logs and Scripts directory, download scripts

We want to make a directory for the scripts, and one for the logs. For example:


    mkdir logs
    mkdir fragPipeScripts
    cd fragPipeScripts
    git clone https://github.com/PatrickvanZalm/MGHPCC.git
    cd ../


#### 4. Update Sbatch commands

In the directory where the scripts are cloned we have to do some manual updating:

1. The Sbatch_*.sh SLURM parameters, which will depend on your local HPC.
2. The location of the Singularity container.


#### 5. update the settings_userinput.sh file

Please following instructions in the settings_userinput.sh file; update the versions of MSFragger, Philosopher and IonQuant.

#### 6. Copy Bruker .d data to your HPC

Depending on your local HPC this will most likely be through SSH or a cloud-based storage, for which you could use [Rclone](https://rclone.org/)

#### 7. Run

All should be set up. The combined.sh script can take care of the whole data pipeline. The script required four inputs in the following order:

1. Input directory (where the Bruker .d's are located)
2. Output directory
3. The number of .d files per MSFragger + PeptideProphet - batch. We suggest a minimum of 20.
4. Location of your Fasta file.

 Starting it could look like the following:

    /your_repository/fragPipeScripts/combined.sh /your_repository/timstoffiles/ /your_repository/results/ 30 /your_repository/FASTA/yourFASTA.fasta.fas
