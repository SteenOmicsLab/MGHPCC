#!/bin/bash

Files=$(find /project/Path-Steen/analysis/workspace/* -maxdepth 0 -type d)

n=0
for f in $Files; do
  ((n++))
  d="/project/Path-Steen/analysis/workspace_temp/$((n / 5))"
  mkdir -p "$d"
  cp -r "$f" "$d"
	echo $f
done








