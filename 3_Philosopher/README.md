# Philosopher

Philosopher is toolbox for the statistical validation of the MSFragger output which is required before quantification. In brief, the following steps are required:

1. peptide assignment validation (PeptideProphet)
2. Protein Inference (ProteinProphet)
3. FDR filtering, database formatting and reporting

In the scripts in this git repositories steps 2 and 3 are put together, which is described in the ProteinProphet sub chapter.

#### PeptideProphet

Similair to writing of mzBIN we again run this part in smaller batches. Example here is with 10.
1. Source settings
2. Copy over Fragpipe tools and the 10 batch samples result directories to the local node's storage
3. Setup a temporary Philosopher workspace on the local node's storage temporary directory
4. Run the Philosopher peptideprophet tool. Settings can be changed here if required. For each input pepXML file it will produce a pep.xml file
5. Test if equal amount of pepXML and pep.xml files, if yes copy over results and cleanup, if no only cleanup.

#### ProteinProphet

1. Source settings
2. Prophetprophet will create the combined.prot.xml file based on all peptideprophet's pep.xml files. Since there is no parallelization here we do not copy any tools or data locally.
3. In a for loop go to each subdirectory:
    1. Create database 
    2. Do the FDR filtering
    3. Create reports file (psm.tsv, peptide.tsv and protein.tsv)

NOTE: we have tried to parallelize the database-FDR-report step but constantly ran into errors. Due to its low computational usage we currently run this in serial (just like regular Fragpipe does). In the future we might re-try to parallelize it again.




