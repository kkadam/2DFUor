#!/bin/bash

newdataloc='/home/kundan/Desktop/2DFUor/MRI_final_bu/MRI_final_20180601/'

for modelname in model*; do

	mkdir -p $(echo $modelname'/DATA')

# Copy and extract the 2d DATA/var*.dat files 
	echo 'Copying var####.dat.gz files to '$modelname'/DATA' 
	cp $(echo $newdataloc$modelname'/DATA/*.gz') $(echo $modelname'/DATA')
	echo 'Extracting var####.dat files to '$modelname'/DATA' 
	gunzip -f $(echo $modelname'/DATA/*.gz')

# Extract and copy 1D files
	if [ -e *.gz ]
	then
		gunzip $(echo $newdataloc$modelname'/*.gz')
	fi
	cp $(echo $newdataloc$modelname'/*.dat') $modelname

# Sort the 2D files according to time, in order to compensate for restarts
	sort -g $(echo $modelname'/ARate.dat') > tempfile0
	mv tempfile0 $(echo $modelname'/ARate.dat') 

# DON'T sort radial.dat files! All separators will stack at the beginning of the file.
#	sort -g $(echo $modelname'/radial.dat') > tempfile0
#	mv tempfile0 $(echo $modelname'/radial.dat') 

	sort -g $(echo $modelname'/massesDust.dat') > tempfile0
	mv tempfile0 $(echo $modelname'/massesDust.dat') 

	sort -g $(echo $modelname'/massesGas.dat') > tempfile0
	mv tempfile0 $(echo $modelname'/massesGas.dat') 

	echo "---"
	echo "All files copied from "$(echo $newdataloc$modelname)" to "$modelname 
	echo "---"
done
