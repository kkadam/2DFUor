#!/bin/bash
#------------------------------------------------------------------
# Specify model name and range
modelname='model3_const_alpha'
workdir=$(echo $modelname"/MOVIES")
cd $workdir

if [[ ! -e $workdir ]]; then
	echo "No directory named "$workdir
#	exit 0
fi

sigfiles=$(echo $modelname"_dGas_")
tempfiles=$(echo $modelname"_temp_")
qfiles=$(echo $modelname"_Qpar_")
alphafiles=$(echo $modelname"_alpha_")
presfiles=$(echo $modelname"_pres_")

ffmpeg -r 5 -f image2 -start_number 2 -i $sigfiles%4d.png $modelname._sigma.mp4
ffmpeg -r 5 -f image2 -start_number 2 -i $tempfiles%4d.png $modelname._temp.mp4
ffmpeg -r 5 -f image2 -start_number 2 -i $qfiles%4d.png $modelname._qpar.mp4
ffmpeg -r 5 -f image2 -start_number 2 -i $alphafiles%4d.png $modelname._alpha.mp4
ffmpeg -r 5 -f image2 -start_number 2 -i $presfiles%4d.png $modelname._pres.mp4

echo "Movies are ready in "$workdir

