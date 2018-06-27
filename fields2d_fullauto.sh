#!/bin/bash
#------------------------------------------------------------------
time0=$(date +"%s")

#-------------------------------------------------------------------
# Specify model name and range
range=200
# Value of range would be 5 or 20 or 200
#-------------------------------------------------------------------

cwd=$PWD


# Setup outdir, depending on range

if [ $range == 20 ]; then
	outdir=IMAGES2D_20AU
elif [ $range == 5 ]; then
	outdir=IMAGES2D_5AU
elif [ $range == 200 ]; then
	outdir=IMAGES2D_200AU
else
	echo "Incorrect value of parameter: range"
	exit 0
fi

# Setup keys and spatial ranges

if [ $range == 20 ]; then
	keyx=15
	keyy=22
elif [ $range == 5 ]; then
	keyx=6.5
	keyy=5.8
elif [ $range == 200 ]; then
	keyx=150
	keyy=220
fi

xmini=$(echo "-"$range)
xmaxi=$(echo $range)
ymini=$xmini
ymaxi=$xmaxi

# Setup cbranges for fields 
if [ $range == 20 ]; then
	sigmin=-0.5
	sigmax=4.0
	Tmin=100
	Tmax=1800
	Qmin=0.8
	Qmax=100
	alphamin=0.0001
	alphamax=0.01
	pmin=0.001
	pmax=4
elif [ $range == 5 ]; then
	sigmin=-0.5
	sigmax=4.0
	Tmin=100
	Tmax=1800
	Qmin=0.8
	Qmax=100
	alphamin=0.0001
	alphamax=0.01
	pmin=0.001
	pmax=4
elif [ $range == 200 ]; then
	sigmin='-1.0'
	sigmax='3.2'
	Tmin='50'
	Tmax='1000'
	Qmin='0.5'
	Qmax='200'
	alphamin='0.001'
	alphamax='0.01'
	pmin='0.00005'
	pmax='0.2'
fi


# Make strings to be used in gnuplot
first_column_au=$(echo '$1/4.8481705933824E-6')
pressure_string=$(echo '$4*10**$3*prop')

# Print information on screen
for modelname in model*; do
	cd $modelname"/DATA"
	echo "-------------------------------------------------------------------"
	echo "Working on model: "$modelname
	echo "Will overwrite directory: "$modelname"/"$outdir 
	echo "Making movies with a distance scale of "$range" AU"
	echo "-------------------------------------------------------------------"


# Iterate over files in the DATA directory

	j=1
	for filename in field*.dat;
	do

		outfilepost=$(echo $(echo $(printf "%04d" $j))".jpg")
#		echo "Processing file: "$filename

# Inside gnuplot

		gnuplot << EOF

# Initialization

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

		set key at $keyx,$keyy

# Plotting Sigma
		set cbrange [$sigmin:$sigmax]
		set output "dGas.$outfilepost"
		splot "$filename" u 2:3:($first_column_au) title 'log10(dGas (g/cm^2)), Time (Myr) = '.columnhead(3)

		set logscale cb

# Plotting T
		set cbrange [$Tmin:$Tmax]
		set output "Temp.$outfilepost"
		splot "$filename" u 2:4:($first_column_au) title 'Temp (K), Time (Myr) = '.columnhead(4)

# Plotting Q
		set cbrange [$Qmin:$Qmax]
		set output "Qpar.$outfilepost"
		splot "$filename" u 2:10:($first_column_au) title 'Qpar, Time (Myr) = '.columnhead(10)

#Plotting alpha
		set cbrange [$alphamin:$alphamax]
		set output "AlphaV.$outfilepost"
		splot "$filename" u 2:11:($first_column_au) title 'AlphaV, Time (Myr) = '.columnhead(11)

#Plotting pressure
		set logscale cb
		prop = 8.3145E-7/2.3333
		set cbrange [$pmin:$pmax]
		set output "Pres.$outfilepost"
		splot "$filename" u 2:($pressure_string):($first_column_au) title 'Pressure (Ba), Time (Myr) = '.columnhead(11)
		unset logscale
		
EOF

		j=$(($j+1))

	done

	mkdir ../$outdir
	mv *.jpg ../$outdir

	echo "--------------------------------------------------------------------"
	echo "Images are ready in "$modelname"/"$outdir
	echo "--------------------------------------------------------------------"

	cd ../$outdir

	rm *.mp4
	ffmpeg -loglevel panic -r 5 -f image2 -start_number 2 -i dGas.%4d.jpg $modelname._dGas.mp4
	ffmpeg -loglevel panic -r 5 -f image2 -start_number 2 -i Temp.%4d.jpg $modelname._Temp.mp4
	ffmpeg -loglevel panic -r 5 -f image2 -start_number 2 -i Qpar.%4d.jpg $modelname._Qpar.mp4
	ffmpeg -loglevel panic -r 5 -f image2 -start_number 2 -i AlphaV.%4d.jpg $modelname._AlphaV.mp4
	ffmpeg -loglevel panic -r 5 -f image2 -start_number 2 -i Pres.%4d.jpg $modelname._Pres.mp4

	time1=$(date +"%s")
	dtime=$(echo "scale=2;($time1-$time0)/60.0" | bc)

	echo "--------------------------------------------------------------------"
	echo "Movies are ready in "$modelname"/"$outdir
	echo "Completed in time "$dtime" min"
	echo "--------------------------------------------------------------------"
	cd $cwd

done
