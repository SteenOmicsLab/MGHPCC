# MSFragger

A regular MSFragger run on timsTOF data first transforms the Bruker .d folder in a .mzBIN file followed by the actual peptide spectrum matching. MSFragger does not parallelize this data-transformation step; instead it runs them one by one. For the analysis of thousands of timsTOF mass spectrometry proteomics samples this was considered a time-sink as well as a waste of computational power. Instead we decided to split it up into two parts:

1. writing of the mzBIN files (Sbatch_write_mzBIN.sh & write_mzBIN.sh)
2. Actual MSFragger run (Sbatch_MSFragger.sh MSFragger.sh)

#### Writing of mzBIN files

Note: user has specified the number of samples per batch in the settings.sh file at this point (more info in combined_and_settings_info.md). Here we use the example of 10 samples per batch.

Steps:
1. Source settings and the specified 10 batch samples
2. Copy over Fragpipe tools and the 10 batch samples raw mass spec files to the local node's storage
3. Make a "fake" FASTA file with just one single protein, to waste minimal time on actual peptide-spectrum atching.
4. Run MSFragger on the 10 samples using the "fake" FASTA file.
5. Test to see if number of Bruker and mzBIN files correspond.
6. If numbers correspond copy mzBIN and mgf files to original data storage directory followed by cleanup, if not corresponding cleanup but no copy to original data storage.

#### MSFragger

steps:
1. Source settings
2. Make a subdirectory for each input file in the results folder and initialize a Philosopher Workspace.
3. Initialize a Philosopher Workspace in the results folder.
4. Run MSFragger using the dbsplits option (as specified in the settings). Since all mzBIN files are already written at this point it will start doing the Peptide Spectrum Matching based on the FASTA file and fragger.params - settings file. RAM usage can be changed here, if needed.
5. Test if there is an equal number of input files and result pepXML files. If yes, copy files over to respective results sub-directory followed by cleanup. If not, only cleanup.


