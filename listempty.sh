#!/bin/bash

searchpath="/project/Path-Steen/analysis/outputfiles_temp_failed/"
outputfile="/project/Path-Steen/analysis/outputfiles_temp_failed/output.txt"

{ find $searchpath -type d -print -maxdepth 1 | \grep -v ^"$searchpath"$ | while read dir; do
  [[ -z $(\ls "$dir" | \grep pepXML$ ) ]] && echo "$dir";
done } > "$outputfile"
