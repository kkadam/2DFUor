#!/bin/bash

modelname='model3_T1100_S100'
Ton=1
Tcrit=1100

xmini='0.015'
xmaxi='0.35'


outdir=TIMEPLOTS
targetdir=$(echo "./"$modelname)
infile1='ARate.dat'
infile2='massesGas.dat'

### Colors
red="#DC143C"
blue="#0000CD"
green="#008000"
# logscale and yrange are set by hand
#####################################

echo "Making temporal plots for model- " $targetdir

cd $targetdir
mkdir $outdir

sum56=$(echo '$5+$6')

# inside gnuplot
gnuplot << EOF
set term jpeg noenhanced
set grid
set xlabel "Time (Myr)"

# 1. plot mean accretion rate on the star
set output "$modelname"."_1-4.jpg"
set xrange [$xmini:$xmaxi]
set yrange [1e-8:1e-4]
set logscale y
set ylabel "M_dor_star_mean (M_sun/yr)"
set format y "%.0tE%+02T"
p "$infile1" u 1:4 w l t  "$modelname"."/"."$infile1"." u 1:4" lt rgb "$red"
unset format y
unset logscale

# 2. plot temperature at the edge of the inner disc
set output "$modelname"."_1-11.jpg"
set xrange [$xmini:$xmaxi]
set yrange [0:2500]
set ylabel "T_inner (K)"
if ($Ton > 0)\
	p "$infile1" u 1:11 w l t  "$modelname"."/"."$infile1"." u 1:11" lt rgb "$red", $Tcrit w l t "T_crit" lt rgb "$green" linewidth 2;\
else \
	p "$infile1" u 1:11 w l t  "$modelname"."/"."$infile1"." u 1:11" lt rgb "$red"
unset logscale

# 3. plot density at the edge of the inner disc
set output "$modelname"."_1-12.jpg"
set xrange [$xmini:$xmaxi]
set yrange [0.1:1e5]
set logscale y
set ylabel "Rho_inner (g/cm^3)"
p "$infile1" u 1:12 w l t  "$modelname"."/"."$infile1"." u 1:12" lt rgb "$red"
unset logscale

# 4. plot alpha at the edge of the inner disc
set output "$modelname"."_1-13.jpg"
set xrange [$xmini:$xmaxi]
set yrange [0.0008:0.02]
set logscale y
set ylabel "alpha_inner"
p "$infile1" u 1:13 w l t  "$modelname"."/"."$infile1"." u 1:13" lt rgb "$red"
unset logscale

# 5. plot total luminosity
set output "$modelname"."_1-5plus6.jpg"
set xrange [$xmini:$xmaxi]
set yrange [0.1:100]
set logscale y
set ylabel "L_star and L_total (L_sun)"
p "$infile1" u 1:6 w l t  "L_star $modelname"."/"."$infile1"." u 1:6" lt rgb "$red", '' u 1:($sum56) w l t "L_total $modelname"."/"."$infile1"." u 1:($sum56)" lt rgb "$blue"
unset logscale


# 6. plot stellar and disk masses
set output "$modelname"."_1-2and6.jpg"
set xrange [$xmini:$xmaxi]
set yrange [0:0.3]
set ylabel "M_star and M_disk (M_sun)"
p "$infile2" u 1:2 w l t  "M_star $modelname"."/"."$infile2"." u 1:2" lt rgb "$red", '' u 1:6 w l t "M_disk $modelname"."/"."$infile2"." u 1:6" lt rgb "$blue"
unset logscale

EOF
# exited gnuplot

mv *.jpg $outdir

echo "Plots are stored in- "$targetdir"/"$outdir


