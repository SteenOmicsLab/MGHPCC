#!/bin/bash

file=$1

#Now we want to move the pepxml files from file directory, to output directory
$philosopherPath peptideprophet --decoyprobs --ppm --accmass --nonparam --expectscore --decoy $decoyPrefix --database $fastaPath /dev/shm/outputfiles/$(basename ${file::-2}).pepXML

