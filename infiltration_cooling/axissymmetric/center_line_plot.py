from matplotlib import pyplot as plt
from matplotlib import colors, cm
import matplotlib.font_manager as fm
import pandas as pd
import numpy as np
import torch
import os

## Input
basefolder = ["uniform_phiC_5em3_D1em4/", "uniform_phiC_5em3_D1em5_R05/"]

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/usr/share/fonts/truetype/msttcorefonts/Arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)

font = {"family": "Arial"}
fsize = 13
figsize = (4.0, 3.5)
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

i = [60, 340]

for j in range(1):  # len(basefolder)):
    filename = basefolder[j] + "out_data_center_line_{:04d}.csv".format(i[j])

    data = pd.read_csv(filename)

    zz = data["y"]
    phi_SiC = data["phi_SiC"]
    void = data["void_fraction"]

    ax.plot(np.abs(zz), phi_SiC, color="b", linewidth=2.0, label="SiC")
    ax.plot(np.abs(zz), void, color="k", linewidth=1.4, label="porosity")

ax.set_xlabel("z (cm)")
ax.legend()
ax.set_ylabel("volume fraction")
ax.set_ylim([0.05, 0.2])
ax.set_xlim([0, 0.6])

fig.tight_layout()
fig.savefig("results.png")
plt.show()
