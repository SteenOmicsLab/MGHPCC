#!/bin/bash
export LC_ALL=C

#source in all info
source $1/settings/settings.sh
philosopherNetworkPath="/project/Path-Steen/Patrick/Fragpipe/tools/philosopher-4.2.1/philosopher"

# #We first clean up all the workspace, this is a lot of data we can get rid of.
for resultdir in $outputdirectory/results/*/
do 
    cd $resultdir
    #First we clean with Philosopher
    $philosopherNetworkPath workspace --clean
done

# #also one clean in the dir above single one
cd $outputdirectory/results/
$philosopherNetworkPath workspace --clean

#Next, we go to our output directory. We zip all files here.
cd $outputdirectory
zip -r all_search_files.zip ./*

#we extract all the actual tsv files we would need.
cp ./results/*.tsv ./
cp ./results/*.csv ./

#Finally, we can delete all the folders since they are in the zip.
rm -r ./results/
rm -r ./logs/
rm -r ./settings/



