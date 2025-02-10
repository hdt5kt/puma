from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import torch

## Input
filename = "volume_check/out.csv"


## Set up plot ------------------------------------------------------------
font = {"family": "monospace"}
fsize = 11
figsize = (5, 4)
lw = 1

plt.rc("font", **font)
plt.rc("font", **font, size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

fig, ax = plt.subplots()
fig.set_size_inches(figsize)


## Main ---------------------------------------------------------------------

data = pd.read_csv(filename)

ax.plot(data["temp"][1:], ((data["feaV"][1:]/data["feaV"][1])**(1/3)-1.0), label="FEA_Volume", color="red", lw=1)

#ax.plot(data["temp"][1:], data["maxdispx"][1:], label="FEA_Volume", color="red", lw=1.75,)

ax.plot(data["temp"][1:], ((data["neml2V"][1:]/data["neml2V"][1])**(1/3)-1.0), label="Mat_NEML2_Volume", color="blue", lw=1)
ax.plot(data["temp"][1:], data["epsxx"][1:], label="eps_xx", color = "black", ls = '--', lw=2.5)
ax.plot(data["temp"][1:], data["epsxx"][1:], label="eps_yy", color = "black", ls = '-.', lw=2.5)
ax.plot(data["temp"][1:], data["epsxx"][1:], label="eps_zz", color = "black", ls = ':', lw=2.5)
ax.set(ylabel="total strain")
ax.set(xlabel="Temperature (K)")
ax.legend(loc="best", title="From", frameon=False)

fig.tight_layout()
plt.show()
