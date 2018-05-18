#!/bin/bash
modelname="model3_T1100_S100"
xmini=0.4
xmaxi=10000
ymini=0.015
ymaxi=0.35

#################################################

infile_dens=$(echo $modelname"/COLORED/dens")
infile_tmpr=$(echo $modelname"/COLORED/tmpr")
infile_Qpar=$(echo $modelname"/COLORED/Qpar")
infile_AlphaV_av=$(echo $modelname"/COLORED/AlphaV_av")

outfile_dens=$(echo $modelname"_dens.jpg")
outfile_tmpr=$(echo $modelname"_tmpr.jpg")
outfile_Qpar=$(echo $modelname"_Qpar.jpg")
outfile_AlphaV_av=$(echo $modelname"_AlphaV_av.jpg")


gnuplot << EOF

	set term jpeg size 1024,768 crop noenhanced
	set size ratio 1
	set pm3d map

# Colorbar options
#######################
set colorbox vertical
set colorbox user origin 0.775,0.15 size 0.05,0.728
#######################

	set logscale cb
	set logscale x
	set xlabel "R (AU)"
	set ylabel "Time (Myr),  $modelname"
	set xrange [$xmini:$xmaxi]
	set yrange [$ymini:$ymaxi]


# Color palette
####################################
# More info - https://github.com/Gnuplotting/gnuplot-palettes
#	load 'gnuplot-palettes/viridis.pal'
#	set palette negative

#	Latest palette sent to Eduard ->
	set palette define (  0 '#000004', 1 '#084594', 2 '#3b4cc0', 3 '#688aef', 4 '#99baff', 5 '#c9d8ef', 6 '#edd1c2', 7 '#e36a53', 8 '#b40426') 

#	Eduard palette yellow pastel for white
#	set palette define (  0 '#000004', 1 '#084594', 2 '#3b4cc0', 3 '#688aef', 4 '#99baff', 5 '#FFF2AE', 6 '#edd1c2', 7 '#e36a53', 8 '#b40426') 
###################################

# Plotting Sigma
#	set cbrange [0.1:1e5]
	set cbrange [0.08:3e4]
	set output "$outfile_dens"
#	set title '\Sigma (g/cm^2)'
	set format cb "%.0tE%+02T"
	sp "$infile_dens" u 1:2:3 
	unset format cb

# Plotting T
	set logscale cb
	set cbrange [40:1300]
#	set title 'Temp (K)'	
	set output "$outfile_tmpr"
	sp "$infile_tmpr" u 1:2:3 

# Plotting Qpar
	set logscale cb
        set cbrange [1:100]
#	set title 'Qpar'
	set output "$outfile_Qpar"
	sp "$infile_Qpar" u 1:2:3 

# Plotting Alpha_av
#        set cbrange [0.0001:0.01]
        set cbrange [0.00006:0.01]
#	set title 'AlphaV\_av'
	set output "$outfile_AlphaV_av"
        set format cb "%.0tE%+02T"
	sp "$infile_AlphaV_av" u 1:2:3 
	unset format cb

EOF




