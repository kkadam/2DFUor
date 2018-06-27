#!/bin/bash
###################
# Rewrites the 2d var*.dat files in DATA directory
# into a format that is readable by gnuplot
### Specify input file & output directory###

for modelname in model2*; do

	time0=$(date +"%s")

	datadir=$(echo $modelname/DATA)
	#res => resolution
	res=512
	nfield=12

	cd $datadir
	pwd

	echo "Working in "$datadir"..." 

	sed '1,15360d' grid.dat > tempo
	# The grid.dat contains res x nin rows of data for the inner boundary
	# This needs to be subtracted, so here 512 x 30 = 15360 rows are removed
	awk -v n=512 '1; NR % n == 0 {print ""}' tempo > tempfile3
	awk '{print $1 " " $2}' tempfile3 > tempfile4

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
		echo "#"${outfields[@]}|awk {'print $0'} >> $outfile
		#echo "#' ${outfields[@]} > $outfile
		paste tempfile4 tempfile2  >> $outfile

		j=$(($j+1))
	done

	rm temp*

	time1=$(date +"%s")
	dtime=$(echo "scale=2;($time1-$time0)/60.0" | bc)

	echo "--------------------------------------------------------------------"
	echo "Field####.dat files are ready in "$datadir 
	echo "Completed in time "$dtime" min"
	echo "--------------------------------------------------------------------"

done
	
exit


