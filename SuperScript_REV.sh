#!/bin/bash

#N is for number of samples per MSFragger Instance
N=5

#Give directory of the .d files
dataDirPath="/project/Path-Steen/analysis/timstoffiles/"

#Load Singularity on the Node
module load singularity


#Delete any that are still on in case.
rm -r /tmp/timstoffiles1/
rm -r /tmp/timstoffiles2/
rm -r /tmp/outputfiles1/
rm -r /tmp/outputfiles2/
rm -r /tmp/msfragger1/
rm -r /tmp/msfragger2/

#Make directories on the NVMe memory of the Node
mkdir -p /tmp/timstoffiles1/
mkdir -p /tmp/timstoffiles2/
mkdir -p /tmp/outputfiles1/
mkdir -p /tmp/outputfiles2/

#Copy the fragpipe files to msfragger directory
cp -r /project/Path-Steen/msfragger/ /tmp/msfragger1/
cp -r /project/Path-Steen/msfragger/ /tmp/msfragger2/

#make msfraggerfiles executable
chmod 770 -R /tmp/msfragger1/
chmod u+x /tmp/msfragger1/tools/philosopher/philosopher
chmod 770 -R /tmp/msfragger2/
chmod u+x /tmp/msfragger2/tools/philosopher/philosopher

#make directory for one .d file. this will function as the bool in the while loop
BoolFile=$(find "/project/Path-Steen/analysis/timstoffiles" -maxdepth 1 -name "*.d" | tail -n 1)

#Run a while loop. it will long as long as there is a directory in the $BoolFile.
#We also renew the $BoolFile at the end of the While loop
while [[ -d $BoolFile ]]
do
	#Select N amount of bruker files. Copy them to /tmp/timstoffiles1 and rename them.
	#Had to add maxdepth. Some .d folders have another .d in them due to transferring to mgf format. This did mess up the code.
	brukerfiles1=$(find "/project/Path-Steen/analysis/timstoffiles" -maxdepth 1 -name "*.d" | tail -n $N)
	echo $brukerfiles1
	cp -r $brukerfiles1 /tmp/timstoffiles1/
	rename -v .d .e $brukerfiles1	
	
	#Do the same thing for the second set. There is a small if statement; dont run if there is no files in brukerfiles2
	brukerfiles2=$(find "/project/Path-Steen/analysis/timstoffiles" -maxdepth 1 -name "*.d" | tail -n $N)
	if [[ -n $brukerfiles2 ]]
	then
		cp -r $brukerfiles2 /tmp/timstoffiles2/
		rename -v .d .e $brukerfiles2
	fi
	
	#Run the MSFraggers. Here we too use a if else based on if there are samples in brukerfiles2
	if [[ -n $brukerfiles2 ]]
	then

	/project/Path-Steen/ShellScripts/Prep_MSfragger1.sh & /project/Path-Steen/ShellScripts/Prep_MSfragger2.sh
	wait #Had to add some Wait commands so that the script will only start copying & removing stuff once BOTH are done.

	else
	/project/Path-Steen/ShellScripts/Prep_MSfragger1.sh
	wait	
	fi

	
	
	#Copy the results file back to the network storage, delete from /tmp/
	if [[ -n $brukerfiles2 ]]
	then
	cp -r /tmp/outputfiles1/* /project/Path-Steen/analysis/workspace/
	cp -r /tmp/outputfiles2/* /project/Path-Steen/analysis/workspace/
	rm -r /tmp/timstoffiles1/*
	rm -r /tmp/timstoffiles2/*
	rm -r /tmp/outputfiles1/*
	rm -r /tmp/outputfiles2/*	
	else
	cp -r /tmp/outputfiles1/* /project/Path-Steen/analysis/workspace/
	rm -r /tmp/timstoffiles1/*
	rm -r /tmp/outputfiles1/*
	fi

	#Final change of the Bool while is used for the while loop.
	echo "TheBoolFile Is Now"
	BoolFile=$(find "/project/Path-Steen/analysis/timstoffiles" -maxdepth 1 -name "*.d" | tail -n 1)
	echo $BoolFile
done

#rename the brukerfiles back to .d
#rename -v .e .d $dataDirPath*.e 

#Remove all the directories on the NVMe
rm -r /tmp/timstoffiles1
rm -r /tmp/timstoffiles2
rm -r /tmp/outputfiles1
rm -r /tmp/outputfiles2

#Make additional folder in /path-Steen/analysis/ called outputfiles_Quant

#Make New Directories, for IonQuant etc.

#copy outputfiles to /tmp/

#Have IonQuant Run over the /tmp/ data

#store in /outputfiles_Quant

#Delete shit

#Done?


rm -r /tmp/msfragger1
rm -r /tmp/msfragger2
#done


