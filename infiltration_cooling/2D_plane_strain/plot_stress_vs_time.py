from matplotlib import pyplot as plt
from matplotlib import colors, cm
import matplotlib.font_manager as fm
import pandas as pd
import numpy as np
import torch
import os

## Input
basefolder = "different_initial_phiC/strain/"
plotfolder = "different_initial_phiC"

E = 150e9

if not os.path.isdir(plotfolder):
    os.mkdir(plotfolder)

postdata = pd.read_csv(basefolder + "solidification_total.csv")
times = postdata["time"]

tscale = 60  # division from seconds

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/usr/share/fonts/truetype/msttcorefonts/Arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)

font = {"family": "Arial"}
fsize = 14
figsize = (4.2, 6)
lw = 1

norm = colors.Normalize(vmin=times.iloc[0] / tscale, vmax=times.iloc[-1] / tscale)
sm = cm.ScalarMappable(norm=norm, cmap="rainbow")

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

thermal = np.zeros((len(times), 3))  # min, max, mean
phase = np.zeros((len(times), 3))  # min, max, mean

for i in range(1, 150):
    filename = basefolder + "solidification_total_component_stress_{:04d}.csv".format(i)
    if not os.path.isfile(filename):
        break
    data = pd.read_csv(filename)
    sh_thermal = (
        1 / 3 * (data["s11_thermal"] + data["s22_thermal"] + data["s33_thermal"]) / E
    )
    thermal[i, :] = [np.min(sh_thermal), np.mean(sh_thermal), np.max(sh_thermal)]

    sh_phase = 1 / 3 * (data["s11_phase"] + data["s22_phase"] + data["s33_phase"]) / E
    phase[i, :] = [np.min(sh_phase), np.mean(sh_phase), np.max(sh_phase)]


ax.fill_between(
    times[:i] / tscale, thermal[:i, 0], thermal[:i, 2], alpha=0.2, color="b"
)
ax.plot(times[:i] / tscale, thermal[:i, 1], color="b", linewidth=1.4)

ax.fill_between(times[:i] / tscale, phase[:i, 0], phase[:i, 2], alpha=0.2, color="k")
ax.plot(times[:i] / tscale, phase[:i, 1], color="k", linewidth=1.4)

ax.set_xlabel("time (hours)")
ax.set_ylabel("hydrostatic stress, $\sigma_h / E$")
ax.set_xlim([0, 5])

fig.tight_layout()
fig.savefig("stress_vs_time.png")
# plt.show()
