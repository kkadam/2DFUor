#------------------------------------------------------------------------
# Description:
# Makes 2D plots of the fields at three distance scales, 5, 20 and 200 AU
import numpy as np
import matplotlib.pyplot as plt 
import sys
import os
from mpl_toolkits.axes_grid1.axes_divider import make_axes_locatable
from mpl_toolkits.axes_grid1.colorbar import colorbar
import matplotlib.colors as colors
import glob
import time
#------------------------------------------------------------------------

# Timing
tInit = time.time()

# Specify target model 
target='model1_const_alpha'
gridfile='grid.dat'
#filename='var0172.dat'
resR=512
resPhi=512

# Specify input and output directories
targetdir = target+'/DATA/'
outdir = target+'/MOVIES'

if not os.path.exists(outdir):
    os.makedirs(outdir)
    print ("Directory "+outdir+" created")
else:
    print ("Directory "+outdir+" already exists")
    print ("Overwriting..")

# Get the list of input files
fileslist = glob.glob(targetdir+'var*.dat')
#fileslist = [targetdir+'var0001.dat', targetdir+'var0172.dat']

fileslist.sort()
infiles = np.hstack(fileslist)
#nt = infiles.size

# Load grid array 
data_grid = np.loadtxt(targetdir+gridfile, skiprows=15360)
radialRaw = data_grid[:,0]
radialRaw = radialRaw/4.8481705933824E-6
phiRaw = data_grid[:,1]

# Make dummy array to append at the beginning, 
# otherwise matplotlib puts stupid colors in the central dataless hole
epsilon = 1e-3
dummyR = [radialRaw[0]-epsilon] * resPhi
dummyPhi = phiRaw[:resPhi]

radial = np.concatenate((dummyR, radialRaw))
phi = np.concatenate((dummyPhi,phiRaw))

X = radial*np.cos(phi)
Y = radial*np.sin(phi)

# Custom colorbar: Black - Blue - off White - Red 
cmap1 = colors.LinearSegmentedColormap.from_list("", ['#000004',  '#084594',  '#3b4cc0',  '#688aef',  '#99baff',  '#c9d8ef',  '#edd1c2', '#e36a53', '#b40426'])
cmap1.set_bad('white',1.0)
cmap1.set_over('#b40426',1.0)
cmap1.set_under('#000004',1.0)

# Loop over files
#--------------------------------------------------
for filename in infiles:
    print ("Working on: "+filename)
    # Load time of the frame
    with open(filename) as f:
        timestring = f.readline()
    timefloat = '{:1.6f}'.format(float(timestring))
    print ('t = '+timefloat)

    # Load data arrays
    data_var = np.loadtxt(filename, skiprows=15361)

    dGasRaw = data_var[:,0]
    tempRaw = data_var[:,1]
    QparRaw = data_var[:,7]
    alphaRaw = data_var[:,8]
    presRaw = 8.3145E-7/2.3333 * tempRaw * 10**dGasRaw

    # stupid 
    dGas = np.concatenate(([1E-10] * resPhi,dGasRaw))
    temp = np.concatenate(([1E-10] * resPhi,tempRaw))
    Qpar = np.concatenate(([-1E10] * resPhi,QparRaw))
    alpha = np.concatenate(([-1E10] * resPhi,alphaRaw))
    pres = np.concatenate(([-1E10] * resPhi,presRaw))

    # Make output filenames
    dGasOutfile = outdir+"/"+target+"_dGas_"+filename[-8:-4]+".png"
    tempOutfile = outdir+"/"+target+"_temp_"+filename[-8:-4]+".png"
    QparOutfile = outdir+"/"+target+"_Qpar_"+filename[-8:-4]+".png"
    alphaOutfile = outdir+"/"+target+"_alpha_"+filename[-8:-4]+".png"
    presOutfile = outdir+"/"+target+"_pres_"+filename[-8:-4]+".png"


    # Plot Pressure
    plotitle = target+", Pressure (Ba)"
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3)
    #fig.subplots_adjust(wspace=0.18)

    ax2.set_title(plotitle, pad=55)
    ax2.set_xlabel("Time ="+timefloat+" Myr",  fontsize=14, labelpad=20)

    im1 = ax1.tripcolor(X, Y, pres, norm=colors.LogNorm(vmin=0.01, vmax=10) , cmap=cmap1,shading='gouraud' )
    ax1.set_xlim([-5, 5])
    ax1.set_ylim([-5, 5])
    ax1_divider = make_axes_locatable(ax1)
    cax1 = ax1_divider.append_axes("top", size="7%", pad="2%")
    cb1 = colorbar(im1, cax=cax1,  orientation="horizontal" )
    cax1.xaxis.set_ticks_position("top")
    cax1.yaxis.set_visible(False)
    ax1.set_aspect('equal')

    im2 = ax2.tripcolor(X, Y, pres, norm=colors.LogNorm(vmin=0.001, vmax=10) , cmap=cmap1,shading='gouraud' )
    ax2.set_xlim([-20, 20])
    ax2.set_ylim([-20, 20])
    ax2_divider = make_axes_locatable(ax2)
    cax2 = ax2_divider.append_axes("top", size="7%", pad="2%")
    cb2 = colorbar(im2, cax=cax2, orientation="horizontal")
    cax2.xaxis.set_ticks_position("top")
    cax2.yaxis.set_visible(False)
    ax2.set_aspect('equal')

    im3 = ax3.tripcolor(X, Y, pres, norm=colors.LogNorm(vmin=1E-4, vmax=1) , cmap=cmap1,shading='gouraud' )
    ax3.set_xlim([-200, 200])
    ax3.set_ylim([-200, 200])
    ax3_divider = make_axes_locatable(ax3)
    cax3 = ax3_divider.append_axes("top", size="7%", pad="2%")
    cb3 = colorbar(im3, cax=cax3, orientation="horizontal")
    cax3.xaxis.set_ticks_position("top")
    cax3.yaxis.set_visible(False)
    ax3.set_aspect('equal')

    fig.set_size_inches(12,6)
    plt.tight_layout()

    #plt.show()
    fig.savefig(presOutfile)
    print ("File saved- "+presOutfile)
    plt.close()


    # Plot Alpha
    plotitle = target+", Alpha"
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3)
    #fig.subplots_adjust(wspace=0.18)

    ax2.set_title(plotitle, pad=55)
    ax2.set_xlabel("Time ="+timefloat+" Myr",  fontsize=14, labelpad=20)

    im1 = ax1.tripcolor(X, Y, alpha, norm=colors.LogNorm(vmin=0.0001, vmax=0.01) , cmap=cmap1,shading='gouraud' )
    ax1.set_xlim([-5, 5])
    ax1.set_ylim([-5, 5])
    ax1_divider = make_axes_locatable(ax1)
    cax1 = ax1_divider.append_axes("top", size="7%", pad="2%")
    cb1 = colorbar(im1, cax=cax1,  orientation="horizontal" )
    cax1.xaxis.set_ticks_position("top")
    cax1.yaxis.set_visible(False)
    ax1.set_aspect('equal')

    im2 = ax2.tripcolor(X, Y, alpha, norm=colors.LogNorm(vmin=0.0001, vmax=0.01) , cmap=cmap1,shading='gouraud' )
    ax2.set_xlim([-20, 20])
    ax2.set_ylim([-20, 20])
    ax2_divider = make_axes_locatable(ax2)
    cax2 = ax2_divider.append_axes("top", size="7%", pad="2%")
    cb2 = colorbar(im2, cax=cax2, orientation="horizontal")
    cax2.xaxis.set_ticks_position("top")
    cax2.yaxis.set_visible(False)
    ax2.set_aspect('equal')

    im3 = ax3.tripcolor(X, Y, alpha, norm=colors.LogNorm(vmin=0.001, vmax=0.01) , cmap=cmap1,shading='gouraud' )
    ax3.set_xlim([-200, 200])
    ax3.set_ylim([-200, 200])
    ax3_divider = make_axes_locatable(ax3)
    cax3 = ax3_divider.append_axes("top", size="7%", pad="2%")
    cb3 = colorbar(im3, cax=cax3, orientation="horizontal")
    cax3.xaxis.set_ticks_position("top")
    cax3.yaxis.set_visible(False)
    ax3.set_aspect('equal')

    fig.set_size_inches(12,6)
    plt.tight_layout()

    #plt.show()
    fig.savefig(alphaOutfile)
    print ("File saved- "+alphaOutfile)
    plt.close()
    

    # Plot Q
    plotitle = target+", Q parameter"
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3)
    #fig.subplots_adjust(wspace=0.18)

    ax2.set_title(plotitle, pad=55)
    ax2.set_xlabel("Time ="+timefloat+" Myr",  fontsize=14, labelpad=20)

    im1 = ax1.tripcolor(X, Y, Qpar, norm=colors.LogNorm(vmin=1, vmax=100) , cmap=cmap1,shading='gouraud' )
    ax1.set_xlim([-5, 5])
    ax1.set_ylim([-5, 5])
    ax1_divider = make_axes_locatable(ax1)
    cax1 = ax1_divider.append_axes("top", size="7%", pad="2%")
    cb1 = colorbar(im1, cax=cax1,  orientation="horizontal" )
    cax1.xaxis.set_ticks_position("top")
    cax1.yaxis.set_visible(False)
    ax1.set_aspect('equal')

    im2 = ax2.tripcolor(X, Y, Qpar, norm=colors.LogNorm(vmin=1, vmax=50) , cmap=cmap1,shading='gouraud' )
    ax2.set_xlim([-20, 20])
    ax2.set_ylim([-20, 20])
    ax2_divider = make_axes_locatable(ax2)
    cax2 = ax2_divider.append_axes("top", size="7%", pad="2%")
    cb2 = colorbar(im2, cax=cax2, orientation="horizontal")
    cax2.xaxis.set_ticks_position("top")
    cax2.yaxis.set_visible(False)
    ax2.set_aspect('equal')

    im3 = ax3.tripcolor(X, Y, Qpar, norm=colors.LogNorm(vmin=1, vmax=1000) , cmap=cmap1,shading='gouraud' )
    ax3.set_xlim([-200, 200])
    ax3.set_ylim([-200, 200])
    ax3_divider = make_axes_locatable(ax3)
    cax3 = ax3_divider.append_axes("top", size="7%", pad="2%")
    cb3 = colorbar(im3, cax=cax3, orientation="horizontal")
    cax3.xaxis.set_ticks_position("top")
    cax3.yaxis.set_visible(False)
    ax3.set_aspect('equal')

    fig.set_size_inches(12,6)
    plt.tight_layout()

    #plt.show()
    fig.savefig(QparOutfile)
    print ("File saved- "+QparOutfile)
    plt.close()


    # Plot T
    plotitle = target+", Temperature (K)"
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3)
    #fig.subplots_adjust(wspace=0.18)


    ax2.set_title(plotitle, pad=55)
    ax2.set_xlabel("Time ="+timefloat+" Myr",  fontsize=14, labelpad=20)

    im1 = ax1.tripcolor(X, Y, temp, vmin=300, vmax=1300, cmap=cmap1,shading='gouraud' )
    ax1.set_xlim([-5, 5])
    ax1.set_ylim([-5, 5])
    ax1_divider = make_axes_locatable(ax1)
    cax1 = ax1_divider.append_axes("top", size="7%", pad="2%")
    cb1 = colorbar(im1, cax=cax1,  orientation="horizontal")
    cax1.xaxis.set_ticks_position("top")
    ax1.set_aspect('equal')

    im2 = ax2.tripcolor(X, Y, temp, vmin=20, vmax=1250, cmap=cmap1,shading='gouraud' )
    ax2.set_xlim([-20, 20])
    ax2.set_ylim([-20, 20])
    ax2_divider = make_axes_locatable(ax2)
    cax2 = ax2_divider.append_axes("top", size="7%", pad="2%")
    cb2 = colorbar(im2, cax=cax2, orientation="horizontal")
    cax2.xaxis.set_ticks_position("top")
    ax2.set_aspect('equal')

    im3 = ax3.tripcolor(X, Y, temp, norm=colors.LogNorm(vmin=10, vmax=1000) , cmap=cmap1,shading='gouraud' )
    ax3.set_xlim([-200, 200])
    ax3.set_ylim([-200, 200])
    ax3_divider = make_axes_locatable(ax3)
    cax3 = ax3_divider.append_axes("top", size="7%", pad="2%")
    cb3 = colorbar(im3, cax=cax3, orientation="horizontal")
    cax3.xaxis.set_ticks_position("top")
    cax3.yaxis.set_visible(False)
    ax3.set_aspect('equal')

    fig.set_size_inches(12,6)
    plt.tight_layout()

    #plt.show()
    fig.savefig(tempOutfile)
    print ("File saved- "+tempOutfile)
    plt.close()



    # Plot Sigma
    plotitle = target+", Sigma log10(g/cm2)"
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3)
    fig.subplots_adjust(wspace=0.1)

    ax2.set_title(plotitle, pad=55)
    ax2.set_xlabel("Time ="+timefloat+" Myr",  fontsize=14, labelpad=20)

    im1 = ax1.tripcolor(X, Y, dGas, vmin=2.4, vmax=4.8, cmap=cmap1,shading='gouraud' )
    ax1.set_xlim([-5, 5])
    ax1.set_ylim([-5, 5])
    ax1_divider = make_axes_locatable(ax1)
    cax1 = ax1_divider.append_axes("top", size="7%", pad="2%")
    cb1 = colorbar(im1, cax=cax1,  orientation="horizontal")
    cax1.xaxis.set_ticks_position("top")
    ax1.set_aspect('equal')

    im2 = ax2.tripcolor(X, Y, dGas, vmin=1.6, vmax=4.8, cmap=cmap1,shading='gouraud' )
    ax2.set_xlim([-20, 20])
    ax2.set_ylim([-20, 20])
    ax2_divider = make_axes_locatable(ax2)
    cax2 = ax2_divider.append_axes("top", size="7%", pad="2%")
    cb2 = colorbar(im2, cax=cax2, orientation="horizontal")
    cax2.xaxis.set_ticks_position("top")
    ax2.set_aspect('equal')

    im3 = ax3.tripcolor(X, Y, dGas, vmin=-0.8, vmax=3.2, cmap=cmap1,shading='gouraud' )
    ax3.set_xlim([-200, 200])
    ax3.set_ylim([-200, 200])
    ax3_divider = make_axes_locatable(ax3)
    cax3 = ax3_divider.append_axes("top", size="7%", pad="2%")
    cb3 = colorbar(im3, cax=cax3, orientation="horizontal")
    cax3.xaxis.set_ticks_position("top")
    ax3.set_aspect('equal')

    fig.set_size_inches(12,6)
    plt.tight_layout()

    fig.savefig(dGasOutfile)
    print ("File saved- "+dGasOutfile)
    plt.close()

print ("Images are ready in: "+outdir)


tFinal = time.time()
print ("Time taken: "+str((tFinal-tInit)/60.0)[:7]+" min")


# A ploar plot can be achieved as follows
#fig = plt.figure()
#ax = fig.add_subplot(111, polar = True)
#plt.axis([0,2*np.pi,0,5])
#print(np.max(dGas), np.min(dGas))
#ax.pcolor(phi,radial,Qpar, norm=colors.LogNorm(vmin=1, vmax=100) , cmap=cmap1,shading='gouraud' )   
#plt.show()

sys.exit()
