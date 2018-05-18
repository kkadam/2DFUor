import numpy as np
import matplotlib.pyplot as plt
#####################################################
 
# Specify target model and radius
targetdir='model1_T1500_S100'

file_ARate=targetdir+"/ARate.dat"

data_ARate = np.loadtxt(file_ARate)

time=data_ARate[:,0]
luminosity=data_ARate[:,4]+data_ARate[:,5]
temperature=data_ARate[:,10]

fig, ax1 = plt.subplots()
plt.xlim((0.12, 0.16))


ax1.set_xlabel("Time (Myr)")
ax1.grid(True, 'major', 'x', ls='--', lw=.5, c='k', alpha=.3)
color = 'tab:red'
ax1.set_ylabel("Luminosity (L_sun)", color=color)
#plt.ylim((0, 150))
ax1.set_ylim([0,100])
f1,=ax1.plot(time, luminosity, color=color,linewidth=0.3,label='Luminosity')
ax1.tick_params(axis='y', labelcolor=color)

ax2 = ax1.twinx()

color = 'tab:blue'
ax2.set_ylabel("T")
ax2.set_ylim((0, 3500))
f2,=ax2.plot(time, temperature, linewidth=0.5,label='Temperature')
ax2.set_ylabel("Temperature_inner (K)", color=color)
ax2.tick_params(axis='y', labelcolor=color)


#legend = ax1.legend(loc='upper right')
#legend = ax2.legend(loc='upper right')

plt.legend([f1,f2],['Luminosity','Temperature'],loc='upper right')

fig.tight_layout()
plt.show()
plt.close()

