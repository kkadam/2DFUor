#!/bin/bash
###################
time0=$(date +"%s")

modelinit="model1"
xmini=0
xmaxi=50          # 180 500 50
xmin_l=1
xmax_l=60         # 200 900 60

ymax_rho=35000          # 45000 35000 35000
ymax_t=2500             # 3000 2500 2500

skip_Myr=3      # 9 9 3
# times 0.01
# = 9 for model1 and 2
# = 3 for model3
#################################
outdir=lcorr
mkdir $outdir
#cd $outdir

for modelname in model3*; do

	echo $modelname
	cutinit=$(grep -n "^ 0\.$skip_Myr.....E-01" $modelname/ARate.dat | head -1 | cut -f1 -d:)
	echo $cutinit
	sed "1,$cutinit d" $modelname/ARate.dat > tempfile0

	### Colors
	red="#DC143C"

	sum56=$(echo '$5+$6')

gnuplot << EOF
		set term jpeg noenhanced size 1024,768
		set grid
		set xlabel "L_total (L_sun)"

	# Correlation with T_inner
		set output "$modelname"."_L-T.jpg"
		set ylabel "T (K)"
		set xrange [$xmini:$xmaxi]
		set yrange [200:$ymax_t]
		p "tempfile0" u ($sum56):11 lt rgb "$red" title "$modelname, T_inner vs L_total"
		
		set logscale
		set xrange [$xmin_l:$xmax_l]
		set yrange [100:10000]
		set output "$modelname"."_L-T_log.jpg"
		p "tempfile0" u ($sum56):11 lt rgb "$red" title "$modelname, T_inner vs L_total"
		unset logscale
		

	# Correlation with rho_inner
		set output "$modelname"."_L-rho.jpg"
		set ylabel "Sigma (g/cm^2)"
		set xrange [$xmini:$xmaxi]
		set yrange [0:$ymax_rho]
		p "tempfile0" u ($sum56):12 lt rgb "$red" title "$modelname, rho_inner vs L_total"

		set logscale
		set output "$modelname"."_L-rho_log.jpg"
		set xrange [$xmin_l:$xmax_l]
		set yrange [1:1E5]
		p "tempfile0" u ($sum56):12 lt rgb "$red" title "$modelname, rho_inner vs L_total"
		unset logscale
		
	# Correlation with alpha_inner
		set output "$modelname"."_L-Alpha.jpg"
		set ylabel "Alpha "
		set xrange [$xmini:$xmaxi]
		set yrange [0:0.01]
		p "tempfile0" u ($sum56):13 lt rgb "$red" title "$modelname, Alpha_inner vs L_total"

		set logscale
		set xrange [$xmin_l:$xmax_l]
		set yrange [0.0001:0.02]
		set output "$modelname"."_L-Alpha_log.jpg"
		p "tempfile0" u ($sum56):13 lt rgb "$red" title "$modelname, Alpha_inner vs L_total"
		unset logscale
		
EOF

	rm tempfile0

done

mv *.jpg $outdir

exit


