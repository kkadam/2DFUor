#****************************************************************************
# sigma-T_equilibrium.py
# Calculates the T vs Sigma curve at "Equilibrium" similar to Bell & Lin 1994 
# using the Semenov opacity table 
# The equation for Sigma comes from Zhu et al 2007, Eq 8, as well as 
# Vorobyov, Akimkin et al 2018, Eq 4 (cooling=viscous heating) 
# The value of density used to calculate opacity is assumed constant
# The value of stellar mass used to calculate angular frequency is assumed constant
#****************************************************************************
from numpy import *
from pylab import *
import sys 

#----------------------------------------------------------------------------
# Initialization
#----------------------------------------------------------------------------

# Specify location of the opacity file 
opacityFile = 'SemenovTable.dat'
outfile = "sigTnew.dat"  

# Specify the simulation parameters
R1    = 0.4162             # Location where the T-Sigma curve is calculated (AU)
Mstar  = 0.31              # Mass of the star (Msun)
denErupt = 1.0E-8          # Approximate density during eruptive phase (g/cm3)

#----------------------------------------------------------------------------

# Physical and astronomical constants
au2cm = 1.495978707E+13   # To convert AU to cm
G     = 6.674E-8          # Gravitational constant in CGS
Msun  = 1.9891E+33        # Golar mass in gram
sb    = 5.6704e-5         # Stefan-Boltzmann constant in CGS
mu    = 2.3333            # Molecular weight Gasmu in the simulation
Rc    = 8.314e7           # Gas constant CGS  
alpha = 0.01		  # Disk alpha from simulation
kb    = 1.380648e-16      # Boltzmann constant in CGS 
mp    = 1.672622e-24      # Mass of the proton

R1    = R1 * au2cm        # Convert R1 to cm
Mstar  = Mstar * Msun     # Convert Mstar to gram


#----------------------------------------------------------------------------
# Define functions
#----------------------------------------------------------------------------

# 1. Find the nearest point to the given value in an array, and return its index
def find_nearest(input_array,value):
    temp_array=np.abs(input_array - value)
    idx = np.argmin(temp_array)
    return idx

# 2. Find Semenov and Planck opacities from the table in Eduard's code- SemenovTable.dat 
def find_semenov(denVal,TVal):
	denLog = np.log10(denVal)
	TLog = np.log10(TVal)
	dataOp = np.loadtxt(opacityFile)
	c0 = dataOp[:,0]
	index1 = find_nearest(c0,denLog)
	denNearest = c0[index1] 

	T = []
	opS = []
	opP = []

	for i in range (0,len(c0)):
	        if dataOp[i,0]==denNearest:
		        T.append(dataOp[i,1])
		        opS.append(dataOp[i,2])
		        opP.append(dataOp[i,3])
	index2 = find_nearest(np.hstack(T),TLog)
	opacitySemenov = 10**(np.hstack(opS)[index2])
	opacityPlanck = 10**(np.hstack(opP)[index2])
#	print ("CGS: ", denVal, TVal, opacity, "Tabled(log10): ", denLog, TLog, np.log10(opacity))

	return (opacitySemenov, opacityPlanck) 


#----------------------------------------------------------------------------
# BEGIN PROGRAM
#----------------------------------------------------------------------------

# Initialize arrays
temperature = np.array(np.arange(500,5000,10))
sigma = np.zeros((int(max(temperature.shape)),2))

# Repeating constants
omega = np.sqrt(G*Mstar/R1**3)
prop = 128/27.0 * mu * sb /Rc  
den = denErupt


# Loop over the temperature range
for j in range(0, int(max(temperature.shape))):
        temp = temperature[j]

# Find opacities
        kappa = find_semenov(den,temp)
        ks = kappa[0]
        kp = kappa[1]
#        print (np.log10(den),np.log10(temp),np.log10(ks),np.log10(kp),)
# Find Sigma from Zhu et al 2007
        sigma[j,1] = (prop/(alpha*omega*ks)*temp**3)**0.5

# Find Sigma from Vorobyov, Akimkin et al 2018 
        cs2 = kb * temp / ( mu * mp )
        aa = 3.0/8 * ks
        bb = 1.0
        cc =  (1.0/kp - 16.0/9 * (sb * temp**4)/(alpha * omega * cs2) )
        
        root1 = (-bb + np.sqrt(bb**2 -4*aa*cc))/(2.0*aa)
        root2 = (-bb - np.sqrt(bb**2 -4*aa*cc))/(2.0*aa)

        sigma[j,0] = max(root1, root2)

#--------------------------------------------------------------------------------------
# Find Sigma from VA2018, with a small constant term 
# IN PROGRESS
        H = 0.0001 * sigma[j,0]
        CC = 9.0/4 * alpha*omega*cs2 
        a1 = 3.0/8 * CC*ks*kp
        b1 = CC*kp + 3.0/8 * H*ks*kp
        c1 = CC+ H*kp - 4*sb*kp*temp**4
        d1 = H

        delta = 18*a1*b1*c1*d1 - 4*b1**3*d1 + b1**2*c1**2 - 4*a1*c1**3 - 27*a1**2*d1**2
#        print (delta)

        delta0 = b1**2 - 3*a1*c1
        delta1 = 2*b1**3 - 9*a1*b1*c1 + 27*a1**2*d1
#        C2 = ( 0.5 * ( delta1 + np.sqrt(delta1**2-4*delta0**3) ) )**(1/3.0)
#        megaroot = -1.0/(3*a1) * (b1 +C2+delta0/C2 )
#        print (megaroot, sigma[j,0])
#--------------------------------------------------------------------------------------

sigT = np.hstack((temperature[:,None],sigma))
np.savetxt(outfile,sigT)
# T(K), Sigma (g/cm3-from Vorobyov), Sigma (g/cm3-from Zhu)
print ("Files "+outfile+" saved")

sys.exit()

