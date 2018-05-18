#!/bin/bash
###################
# Rewrites the 2d var files into a format that is readable by gnuplot
### Specify input file & output directory###

modelname="model3_const_alpha"
datadir=$(echo $modelname/DATA)
#res => resolution
res=512
nfield=12
outfile=fields.dat

cd $datadir
pwd

#gunzip *.gz

echo "Working in "$datadir"..." 

j=1
for filename in ./var*.dat; 
#for filename in ./var0001.dat; 
	do

		echo "Processing file: " $j $filename

		infile=$filename
		outfile=$(echo "field"$(echo $(printf "%04d" $j))".dat")
		ts=$(awk 'NR==1 {print $1}' $infile)		
		twelve_timestamps=$(echo $ts $ts $ts $ts $ts $ts $ts $ts $ts $ts $ts $ts ) 
#		echo "# Time "$(awk 'NR==1 {print $1}' $infile) > $outfile
		echo " Time (pc)" $twelve_timestamps > $outfile

		sed -e '1,15361d' $infile > tempfile1
		awk -v n=512 '1; NR % n == 0 {print ""}' tempfile1 > tempfile2
		awk -v n=512 '1; NR % n == 0 {print ""}' grid.dat > tempfile3
		echo "#"${outfields[@]}|awk {'print $0'} >> $outfile
		#echo "#' ${outfields[@]} > $outfile
		awk '{print $1 " " $2}' tempfile3 > tempfile4
		paste tempfile4 tempfile2  >> $outfile

		j=$(($j+1))
	done

exit



rm tempfile



