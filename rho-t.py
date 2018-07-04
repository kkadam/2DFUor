#****************************************************************************
# rho-t.py
# Calculates density at specified radius (R1) as a function of time
# Input is files from COLORED directory
# Output is stored in TIMEPLOTS
# Output file rho_<R1>AU contains time,denR1,HR1,sigR1,TR1
#****************************************************************************

from numpy import *
from pylab import *
import sys
import pandas as pd

# ----------------------------------------------------
# Model parameters
# ----------------------------------------------------
modelname = 'model1_T1100_S100'

R1 = 0.4      # Radius for the T-Sigma plot
nx = 512      # Resolution if the simulation


# Define functions
# Find the index corresponding to the nearest value
def find_nearest(input_array,value):
    temp_array=np.abs(input_array - value)
    idx = np.argmin(temp_array)
    return idx

# Find the closest Semenov opavity from given density and termperature
def find_semenov(denVal,TVal):
	denLog = np.log10(denVal)
	TLog = np.log10(TVal)
	dataOp = np.loadtxt(opacityFile)
	c0 = dataOp[:,0]
	index1 = find_nearest(c0,denLog)
	denNearest = c0[index1] 	

	T = []
	op = []
	for i in range (0,len(c0)):
		if dataOp[i,0]==denNearest:
			T.append(dataOp[i,1])
			op.append(dataOp[i,2])

	index2 = find_nearest(np.hstack(T),TLog)
	opacity = 10**(np.hstack(op)[index2])

# Tests
#	print (dataOp.shape)
#	print ("CGS: ", denVal, TVal, opacity, "Tabled(log10): ", denLog, TLog, np.log10(opacity))

	return opacity

#print (find_semenov(1e-8,1300))
#sys.exit()

# ----------------------------------------------------
# Start program
# ----------------------------------------------------

# Import Sigma, T and H data
dataSig = np.loadtxt(modelname+'/COLORED/dens')
dataT = np.loadtxt(modelname+'/COLORED/tmpr')
dataH = np.loadtxt(modelname+'/COLORED/SheightVert')

# Construct R and time arrays
s0=dataSig[:,0]
s1=dataSig[:,1]

ny=int(len(s1)/nx)

temparray0 = s0.reshape(ny,nx) 
radial = temparray0[0,:]

temparray1 = s1.reshape(ny,nx)
time = temparray1[:,0]

# Find the index where the radius is closest to specified R
R1_index=find_nearest(radial,R1)
print ("R1_index",R1_index,"At",radial[R1_index])

# Construct Sigma, T and H data arrays
s2=dataSig[:,2]
sigEvol = s2.reshape(ny,nx) 
sigR1 = sigEvol[:,R1_index]

t2=dataT[:,2]
TEvol = t2.reshape(ny,nx) 
TR1 = TEvol[:,R1_index]

h2=dataH[:,2]
HEvol = h2.reshape(ny,nx) 
HR1 = HEvol[:,R1_index]
HR1 = HR1 * 3.08567758128E+18  # Convert H from pc to cm

# Find density
denR1 = 1/(np.sqrt(2*np.pi)) * sigR1/HR1  


# Save density in a file
outfile = modelname+'/TIMEPLOTS/'+'rho_'+str(radial[R1_index])+'AU'
np.savetxt(outfile,np.column_stack((time,denR1,HR1,sigR1,TR1)))
print ("File "+outfile+" saved")


