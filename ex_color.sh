#!/bin/bash
###################

### Specify input file & output directory###
targetdir=./model1_T1500_S100
infile_name="radial.dat" 
outdir=COLORED
#res => resolution
res=512
nfield=16
declare -a outfields=('g32b' 'dx2a' 'torqueG' 'torqueV' 'angvel' 'radvel' 'dens' 'tmpr'\
	'Qpar' 'SheightVert' 'muav' 'TempIrrad' 'cosGamma' 'TauR_av' 'TauP_av' 'AlphaV_av') 
############################


cd $targetdir
pwd
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

cp tempfile0 tempfile_test


#Clean beginning and end of the file
sed -i '/^	*$/d' tempfile0
#Don't know why above line does not remove last line also, which begins with a tab!
sed -i '$ d' tempfile0
sed -i '$ d' tempfile0
rm tempfile1

grep -B 1 --no-group-separator ========================================== ../radial.dat | grep -v = > tempfile2


#Abcissa (R) and ordinate (time)
for i in `seq 2 $(($ntime+1))`;
        do
#		echo $i
                awk '{print $1}' tempfile0 >> tempfile1
		for j in `seq 1 $res`;
			do
				awk -v x=$(($i-1)) 'NR==x {print $0}' tempfile2 >> tempfile3
			done	
                echo " " >> tempfile1
                echo " " >> tempfile3
        done

for fn in "${outfields[@]}";
        do
		paste tempfile1 tempfile3 > $fn
	done

rm tempfile1 tempfile2 tempfile3



# filling third column with data fields
#echo "nfield = "$nfield
#echo "ntime = " $ntime
j=1
for fn in "${outfields[@]}";
        do
		echo $j ${outfields[$(($j-1))]} 
                for i in `seq $j $nfield $(($nfield*$ntime))`;
                        do
#                               echo $i,$j, $fn
                                awk -v x=$i '{print $x}' tempfile0 >> tempfile1
				echo " " >> tempfile1
                        done
                paste $fn tempfile1 > tempfile2
		mv tempfile2 $fn
                j=$(($j+1))
		rm tempfile1
        done



echo "Look in the directory "$targetdir"/"$outdir 



