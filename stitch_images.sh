#!/bin/bash
###################

modelname='model1_T1300_S100'
outdir=IMAGES2D


cd $modelname"/DATA"

cd ../$outdir

pwd

ffmpeg -r 6 -f image2 -start_number 2 -i dGas.%4d.jpg $modelname._dGas.mp4
ffmpeg -r 6 -f image2 -start_number 2 -i Temp.%4d.jpg $modelname._Temp.mp4
ffmpeg -r 6 -f image2 -start_number 2 -i Qpar.%4d.jpg $modelname._Qpar.mp4
ffmpeg -r 6 -f image2 -start_number 2 -i AlphaV.%4d.jpg $modelname._AlphaV.mp4

echo "Movies are ready in "$modelname"/"$outdir


