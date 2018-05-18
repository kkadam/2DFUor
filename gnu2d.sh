#!/bin/bash
###################

modelname='model1_T1100_S100'
outdir=IMAGES2D_zoom4
cd $modelname"/DATA"
xmini=-4
xmaxi=4
ymini=-4
ymaxi=4

keyx=5.5
keyy=4.5
#keyx=320  Keys for xmini,ymini=200
#keyy=250

############################################################################

first_column_au=$(echo '$1/4.8481705933824E-6')

echo "-------------------------------------------------------------------"
echo "Working on model: "$modelname
echo "Will overwrite directory: "$modelname"/"$outdir 
echo "-------------------------------------------------------------------"

j=1
for filename in ./field*.dat;
do

        outfilepost=$(echo $(echo $(printf "%04d" $j))".jpg")
	echo "Processing file: "$filename

	gnuplot << EOF
	set term jpeg size 1024,768
	set size ratio 1
	set angles radians
	set mapping cylindrical
	set pm3d map

        set palette define (  0 '#000004', 1 '#084594', 2 '#3b4cc0', 3 '#688aef', 4 '#99baff', 5 '#c9d8ef', 6 '#edd1c2', 7 '#e36a53', 8 '#b40426') 


	set xlabel "X (AU)"
	set ylabel "Y (AU)"
	set xrange [$xmini:$xmaxi]
	set yrange [$ymini:$ymaxi]

#	set grid
	set key at $keyx,$keyy

# Plotting Sigma
	set cbrange [-1:4]
	set output "dGas.$outfilepost"
	splot "$filename" u 2:3:($first_column_au) title 'log10(dGas (g/cm^2)), Time (Myr) = '.columnhead(3)

	set logscale cb
#        set key at $keyx,$keyy

# Plotting T
        set cbrange [100:2000]
	set output "Temp.$outfilepost"
	splot "$filename" u 2:4:($first_column_au) title 'Temp (K), Time (Myr) = '.columnhead(4)

# Plotting Q
        set cbrange [0.8:100]
	set output "Qpar.$outfilepost"
	splot "$filename" u 2:10:($first_column_au) title 'Qpar, Time (Myr) = '.columnhead(10)

#Plotting alpha
        set cbrange [0.0001:0.01]
	set output "AlphaV.$outfilepost"
	splot "$filename" u 2:11:($first_column_au) title 'AlphaV, Time (Myr) = '.columnhead(11)

EOF

	j=$(($j+1))

done

mkdir ../$outdir
mv *.jpg ../$outdir


echo "--------------------------------------------------------------------"
echo "Images are ready in "$modelname"/"$outdir
echo "--------------------------------------------------------------------"
cd ../$outdir

ffmpeg -r 5 -f image2 -start_number 2 -i dGas.%4d.jpg $modelname._dGas.mp4
ffmpeg -r 5 -f image2 -start_number 2 -i Temp.%4d.jpg $modelname._Temp.mp4
ffmpeg -r 5 -f image2 -start_number 2 -i Qpar.%4d.jpg $modelname._Qpar.mp4
ffmpeg -r 5 -f image2 -start_number 2 -i AlphaV.%4d.jpg $modelname._AlphaV.mp4


echo "--------------------------------------------------------------------"
echo "Movies are ready in "$modelname"/"$outdir
echo "--------------------------------------------------------------------"


