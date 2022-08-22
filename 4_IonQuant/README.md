# IonQuant

Similairly to MSFragger, IonQuant first imports the data into a quantindex format before it actually starts the quantification. Here again we use a parallelization approach by first lettering IonQuant write the quantindex files in batches (Sbatch_write_quantindex.sh and write_quantindex.sh) followed by the actual quantification (Sbatch_IonQuant.sh and IonQuant.sh).

#### Write quantindex

We did notice less I/O processes for Ionquant than for MSFragger and after testing no benefit was found by copying over the raw mass spectrometry data to the local node, which we therefore do not do here.

1. Source settings
2. Copy Fragpipe tools over to local node
3. Specify the .pepXML files IonQuant has to work on.
4. Write the quantindex files. 
5. If all quantindex files written exit 0, else exit 1. In both cases, remove local fragpipe tools.

#### IonQuant

With all the quantindex files written we can now swiftly start the data quantification. 

1. Source settings
2. IonQuant needs a list of the psm.tsv files. We choose to just make a (very) long string which specifies the location of each psm.tsv file. We do this by looping over the results directory and append the specific psm.tsv location to it.
3. Start IonQuant with this long string of psm.tsv files as well as all other settings. User can change quantification settings herein, if required.
