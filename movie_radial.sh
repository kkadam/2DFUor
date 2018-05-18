#!/bin/bash
# Check the following
ntimes=225
cd ./EXTRACTED
outdir=movies
declare -a fields=('g32b' 'dx2a' 'torqueG' 'torqueV' 'angvel' 'radvel' 'dens' 'tmpr'\
        'Qpar' 'SheightVert' 'muav' 'TempIrrad' 'cosGamma' 'TauR_av' 'TauP_av' 'AlphaV_av') 
declare -a y_label=('g32b' 'dx2a' 'torqueG' 'torqueV' 'angvel' 'radvel' 'dens' 'tmpr'\
        'Qpar' 'SheightVert' 'muav' 'TempIrrad' 'cosGamma' 'TauR_av' 'TauP_av' 'AlphaV_av') 

#declare -a y_label=('Sigma  log10(g/cm^3)')
declare -a y_logflag=('0' '0' '0' '0' '1' '0' '0' '0'\
	'1' '0' '0' '0' '0' '1' '1' '1')
declare -a x_logflag=('0' '0' '1' '1' '1' '1' '1' '1'\
	'1' '1' '1' '1' '1' '1' '1' '1')
declare -a xmini=('' '' '' '' '' '' '' ''\
	'' '' '' '' '' '' '' '')
declare -a xmaxi=('' '' '' '' '' '' '' ''\
	'' '' '' '' '' '' '' '')
declare -a ymini=('' '' '' '' '' '' '' ''\
	'' '' '' '' '' '' '' '')
declare -a ymaxi=('' '' '' '' '' '' '' '1500'\
	'' '' '' '' '' '' '' '')
############################################


#declare -a x_logflag=('1')
#declare -a xmini=('')
#declare -a xmaxi=('')
#declare -a ymini=('0.001')
#declare -a ymaxi=('100000')

if [ ! -e $outdir ]
then
	mkdir $outdir
fi


# Iterate over files in the array "fields" 
i=0
for fn in "${fields[@]}";
do
	echo "Making images for "${fields[$i]}, $i
	gnuplot << EOF
	set term jpeg
	set grid
	set xlabel 'R (AU)'
	set ylabel "${y_label[$i]}"

	if (${y_logflag[$i]} > 0) set logscale y
	if (${x_logflag[$i]} > 0) set logscale x

	do for [i=2:$ntimes] {
        	outfile = sprintf("$outdir/${fields[$i]}%010.0f.jpg",i)
        	set output outfile
#        	plot [${xmini[$i]}:${xmaxi[$i]}][${ymini[$i]}:${ymaxi[$i]}] "${fields[$i]}" using 1:i title 'Time (Myr) = '.columnhead(i) w l lw 2
#       	plot "${fields[$i]}" using 1:i title 'Time (Myr) = '.columnhead(i) w l lw 2
       	plot [${xmini[$i]}:${xmaxi[$i]}][${ymini[$i]}:${ymaxi[$i]}] "${fields[$i]}" using 1:i title 'Time (Myr) = '.columnhead(i) w l lw 2

	}
EOF
	let "i++"
done

#Make movies!
cd $outdir
rm *.mp4

for fn in "${fields[@]}";
do
        ffmpeg -r 10 -f image2 -start_number 2 -i $fn%10d.jpg $fn.mp4
done

rm *.jpg






