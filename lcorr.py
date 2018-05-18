import numpy as np
import matplotlib.pyplot as plt
#####################################################

# Specify target model and radius
targetdir='model1_T1500_S100'
res = 512
R1=2.0
R2=1.0

# Make file strings
file_ARate=targetdir+"/ARate.dat"
file_tmpr=targetdir+'/COLORED/tmpr'


# Define functions
# Find the index corresponding to the nearest value
def find_nearest(input_array,value):
    temp_array=np.abs(input_array-value)
    idx = np.argmin(temp_array)
    return idx

# Load data and make 1D arrays 
data_ARate = np.loadtxt(file_ARate)
data_tmpr = np.loadtxt(file_tmpr)

time_hf=data_ARate[:,0]
luminosity_hf=data_ARate[:,4]+data_ARate[:,5]

time_lf=data_tmpr[:,1][::res]
radius_lf=data_tmpr[:,0][:res]

#length_lf=time_lf.shape[0]
#length_hf=time_hf.shape[0] 
#print (length_lf, length_hf)

# Find the index where the radius is closest to specified R
R1_index=find_nearest(radius_lf,R1)
print ("R1_index",R1_index)

# Make an array of field values (temperature) at this radius
temparray1=data_tmpr[:,2][R1_index:]
tmpr_lf_R1=temparray1[::res]

# Find total luminosity corresponding to time closest to the low frequency array
# Also error values
luminosity_list=[]
l_err_list=[]
T_err_list=[]
i=1
for time in time_lf[1:-1]:
    close_index=find_nearest(time_hf,time)
#    print (i, time, close_index, time_hf[close_index], luminosity_hf[close_index])

    luminosity_list.append(luminosity_hf[close_index])
    l_pseudoerror=np.maximum(
        np.abs(luminosity_hf[close_index] - luminosity_hf[close_index-1]),
        np.abs(luminosity_hf[close_index] - luminosity_hf[close_index+1]))

    T_pseudoerror=np.maximum(
        np.abs(tmpr_lf_R1[i] - tmpr_lf_R1[i-1]),
        np.abs(tmpr_lf_R1[i] - tmpr_lf_R1[i+1]))

    l_err_list.append(l_pseudoerror)
    T_err_list.append(T_pseudoerror)

    i = i+1

luminosity_lf=np.hstack(luminosity_list)
l_err_lf=np.hstack(l_err_list)
T_err_lf=np.hstack(T_err_list)

#print (luminosity_lf)
print (luminosity_lf.shape)

final=np.column_stack((time_lf[1:-1], tmpr_lf_R1[1:-1], T_err_lf, luminosity_lf, l_err_lf))


#print (final)
#print (final.shape)

np.savetxt("luminosity_correlation_2AU", final)

test=np.column_stack((time_hf,luminosity_hf))
np.savetxt("test",test)

exit()
