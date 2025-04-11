from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import matplotlib.font_manager as fm
import torch

## Input
filename = "solution1/out.csv"
tscale = 60  # seconds to xxx

tscale = 60  # division from seconds

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/usr/share/fonts/truetype/msttcorefonts/Arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)


## Set up plot ------------------------------------------------------------
font = {"family": "Arial"}
fsize = 11.5
figsize = (3.2, 5.4)
lw = 1

plt.rc("font", size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title


## Set up plot ------------------------------------------------------------

fig, ax = plt.subplots(3, 1)
fig.set_size_inches(figsize)


## Main ---------------------------------------------------------------------

data = pd.read_csv(filename)

ax[0].plot(data["temp"][1:], data["ws"][1:], label="char", color="red")
ax[0].plot(data["temp"][1:], data["wp"][1:], label="SiC", color="blue")
ax[0].plot(data["temp"][1:], data["wb"][1:], label="PR", color="black")
ax[0].plot(data["temp"][1:], data["wgcp"][1:], label="close pore gas", color="purple")
ax[0].set(ylabel="weight fraction")
# ax[0].set_ylim((-1, 15))
# ax[0].legend(loc="best", frameon=False)

ax[1].plot(data["temp"][1:], data["phis"][1:], label="char", color="red")
ax[1].plot(data["temp"][1:], data["phip"][1:], label="SiC", color="blue")
ax[1].plot(data["temp"][1:], data["phib"][1:], label="PR", color="black")
ax[1].plot(data["temp"][1:], data["phiop"][1:], label="void", color="purple")
ax[1].plot(data["temp"][1:], data["phigcp"][1:], label="void", color="green")
# ax[1].legend(loc="upper right", frameon=False)
# ax[1].set_ylim((-0.05, 0.85))
ax[1].set(ylabel="volume fraction")

ax[2].plot(data["temp"][1:], data["V"][1:], color="black")
ax[2].set(ylabel="element volume ($m^3$)")
ax[2].set(xlabel="Temperature (K)")
# ax[2].set_ylim((0.01, 0.045))


fig.tight_layout(pad=0.6)
fig.savefig("results.png")
plt.show()
