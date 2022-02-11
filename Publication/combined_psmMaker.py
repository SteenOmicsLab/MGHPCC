import pandas as pd
import glob
import sys

#find all psm.tsv files that are directly in the sample file.
#Note; in the hidden .meta file there is also a psm.tsv. We dont use that
outputdirectory = str(sys.argv[1])
directories = glob.glob(outputdirectory + "/*/psm.tsv")

#loop over each of the identified psm.tsv files.
#We just append them, since it follows the exact same structure
for i, name in enumerate(directories):
    
    if i ==0:
        
        combined_psm = pd.read_csv(name, sep='\t')
        
    else:
        psm_i = pd.read_csv(name, sep='\t')
        combined_psm = combined_psm.append(psm_i)

#write to tsv format
results.to_csv(outputdirectory + "/psm.tsv", sep='\t', index = False)

