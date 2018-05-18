#!/bin/bash
###################

### Specify input file & output directory###
infile_name="radial.dat" 
outdir=EXTACTED
#res => resolution
res=512
nfield=16
declare -a outfields=('g32b' 'dx2a' 'torqueG' 'torqueV' 'angvel' 'radvel' 'dens' 'tmpr'\
	'Qpar' 'SheightVert' 'muav' 'TempIrrad' 'cosGamma' 'TauR_av' 'TauP_av' 'AlphaV_av') 
############################


infile=$(echo "../"$infile_name)


if [ ! -e $infile_name ]
then
	echo "There's no "$infile_name" file here!"
	exit
fi

echo "Make sure the resolution is "$res
echo "Make sure file "$infile_name" contains-"
echo ${outfields[@]}


if [ -e $outdir ]
then
	rm -r $outdir
fi
mkdir $outdir
cd $outdir 



if [ -e tempfile0 ]
then
	rm tempfile0
fi
touch tempfile0

#ntime => number of times the 2d profiles are outputted, i.e. timesteps
ntime=$(grep -o '==========================================' $infile | wc -l)
#echo "ntime = "$ntime

#Rearrange the input file into a series of columns
echo "Rearranging input file, total records "$(($ntime+1))
echo "..."
for i in `seq 2 $(($ntime+1))`;
        do
		echo "On record number " $i "of" $(($ntime+1))
		cp tempfile0 tempfile1
		cat $infile | awk -v i="$i" '{print $i}' FS="=========================================="\
	 RS="" > tempfile2
		paste tempfile1 tempfile2 > tempfile0
        done    

#Clean beginning and end of the file
sed -i '/^	*$/d' tempfile0
#Don't know why above line does not remove last line also, which begins with a tab!
sed -i '$ d' tempfile0
sed -i '$ d' tempfile0


#Make individual field files from tempfile0
if [ -e tempfile1 ]
then
        rm tempfile1 tempfile2 
fi

echo "Making output files..."
j=1
for fn in "${outfields[@]}";
	do
		touch tempfile1
		echo $j ${outfields[$j]} 
		for i in `seq $j $nfield $(($nfield*$ntime))`;
        		do
#				echo $i,$j, $fn
				awk -v x=$i '{print $x}' tempfile0 > tempfile2
				paste tempfile1 tempfile2 > tempfile3
				mv tempfile3  tempfile1
			done
		mv tempfile1 $fn
		j=$(($j+1))
	done

if [ -e tempfile1 ]
then
        rm tempfile1 tempfile2 tempfile3
fi
#Abcissa 
for fn in "${outfields[@]}";
	do
		awk '{print $1}' g32b > tempfile1
		paste tempfile1 $fn >tempfile2
		mv tempfile2 $fn
	done


# Make and write the headers
echo "Writing headers..."
headflag=1
if [ $headflag -eq 1 ] 
then
	echo "top " $infile
        num=$(($res+2))
        tempvar1='#'$(awk '{print FNR}' RS="==========================================" $infile)
	zeroline=$(echo "${tempvar1%?}")
        firstline='#'$(awk -v num="$num" 'NR % (num) == 1 {print NR}'  $infile)
        secondline='0.0  '$(awk -v num="$num" 'NR % (num) == 1 {print $0}' $infile)

#	echo $num
#	echo $zeroline
#	echo $firstline
#	echo $secondline


	for fn in "${outfields[@]}";
		do
			echo "# Total profiles = $ntime" > tempfile3 
			echo "# Plain number" >> tempfile3
			echo $zeroline >> tempfile3
			echo "# Line number in radial.out" >> tempfile3
			echo $firstline >> tempfile3
			echo "# Time (Myr)" >> tempfile3
			echo $secondline >> tempfile3

			cat tempfile3 $fn > tempfile4
			mv tempfile4 $fn
			rm tempfile*
		done
fi

echo "Done!"


