import pandas as pd
import glob
import sys

#find all protein.tsv files that are directly in the sample file.
#Note; in the hidden .meta file there is also a protein.tsv. We dont use that
outputdirectory = str(sys.argv[1])
directories = glob.glob(outputdirectory + "/*/protein.tsv")

#loop over each of the identified protein.tsv files.
for i, name in enumerate(directories):
    
    print(i)	
	    
    #extract sample name    
    sampleID = name.split("/")[-2]
    
    #If the first 0 we call that the results file
    if i == 0:
        results = pd.read_csv(name, sep='\t')
        
        # Select only columns that are common between all protein.tsv files
        # Note: we do a slightly different order here compared to protein.tsv
        # We followed combined_protein order. 
        results = results[["Group",
                           "SubGroup",
                           "Protein",
                           "Protein ID",
                           "Entry Name",
                           "Gene",
                           "Length",
                           "Percent Coverage",
                           "Organism",
                           "Protein Existence",
                           "Protein Description",
                           "Protein Probability",
                           "Top Peptide Probability",
                           "Stripped Peptides"]]
        
        #Combined_protein.tsv has slightly different column names. Change accordingly...
        results.columns = ["Protein Group",  #CHANGED
                           "SubGroup",
                           "Protein",
                           "Protein ID",
                           "Entry Name",
                           "Gene Names", #CHANGED
                           "Protein Length", #CHANGED
                           "Coverage", #CHANGED
                           "Organism",
                           "Protein Existence",
                           "Protein Description",
                           "Protein Probability",
                           "Top Peptide Probability",
                           "Unique Stripped Peptides"] #CHANGED
        
        #There's also 3 summarized spectral count columns. Lets add those and fill with 0 for now
        results["Summarized Total Spectral Count"] = 0
        results["Summarized Unique Spectral Count"] = 0
        results["Summarized Razor Spectral Count"] = 0
        
    #Import the sample
    sample_i = pd.read_csv(name, sep='\t')
    
    #select common column + ion,count,intensity columns
    #Note, here again the order is slightly different than the protein.tsv file
    sample_i = sample_i[["Protein",
                           "Total Spectral Count",
                           "Unique Spectral Count",
                           "Razor Spectral Count",
                           "Total Peptide Ions",
                           "Unique Peptide Ions",
                           "Razor Peptide Ions",
                           "Total Intensity",
                           "Unique Intensity",
                           "Razor Intensity"]]
    
    #change column names so that it has the ID in it
    #Following abacus, peptide seems to be changed to Ion
    sample_i.columns = ["Protein",
                        sampleID +" Total Spectral Count",
                        sampleID +" Unique Spectral Count",
                        sampleID +" Razor Spectral Count",
                        sampleID +" Total Ion Ions",
                        sampleID +" Unique Ion Ions",
                        sampleID +" Razor Ion Ions",
                        sampleID +" Total Intensity",
                        sampleID +" Unique Intensity",
                        sampleID +" Razor Intensity"]
    
    #Now we join the results with the sample_i. This will repeat for each file in the loop
    results = pd.merge(results, sample_i, how = "left", on = "Protein")
        
#write to tsv format
results.to_csv(outputdirectory + "/combined_protein.tsv", sep='\t', index = False)

