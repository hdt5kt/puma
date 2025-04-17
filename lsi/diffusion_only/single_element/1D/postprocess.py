from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import matplotlib.font_manager as fm
import torch

## Input
filename = "solution1/out.csv"
tscale = 60  # seconds to xxx
l_c = 100e-4  # cm

tscale = 60  # division from seconds

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/usr/share/fonts/truetype/msttcorefonts/Arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)


## Set up plot ------------------------------------------------------------
font = {"family": "Arial"}
fsize = 12.5
figsize = (8, 4)
lw = 1

plt.rc("font", size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

# fig, ax = plt.subplots(1, 2)
# fig.set_size_inches(figsize)


## Main ---------------------------------------------------------------------

data = pd.read_csv(filename)

# ax[0].plot(data["time"][1:] / tscale, data["alpha"][1:])
# ax[0].set(ylabel="Silicon substance (mol/cm3)")
# ax[0].set(xlabel="time (hours)")
#
# ax[1].stackplot(
#    data["time"][1:] / tscale,
#    data["phi_C"][1:],
#    data["phi_SiC"][1:],
#    data["phi_Si"][1:],
#    1 - data["phi_Si"][1:] - data["phi_C"][1:] - data["phi_SiC"][1:],
#    colors=["black", "red", "blue", "white"],
#    labels=["C", "SiC", "Si"],
# )
## ax[1].set_ylim((0, 1))
# ax[1].legend(bbox_to_anchor=(1, 0.5), loc="center left", frameon=False)
# ax[1].set(xlabel="time (hours)", ylabel="composition volume fraction")

# fig.tight_layout()

exp_data = np.array(
    [
        [10, 20, 40, 60, 120, 180, 300],
        [4.4, 9.8, 7.8, 8.6, 8.0, 10.2, np.nan],
        [7.6, 8.2, np.nan, np.nan, 10.8, 9.0, np.nan],
        [np.nan, 8.4, 8.2, 8.0, 8.8, 11.2, 12.8],
    ]
)

fig2, ax2 = plt.subplots()
fig2.set_size_inches((3.45 * 1.2, 2.93 * 1.2))
ro = (1 - data["phi_C"][1:]) ** (1 / 2)
ri = (1 - data["phi_C"][1:] - data["phi_SiC"][1:]) ** (1 / 2)
deltaP = ro - ri

ax2.plot(
    exp_data[0, :],
    exp_data[1, :],
    "^",
    color="black",
    markerfacecolor="none",
    label="T=1430 C",
)
ax2.plot(
    exp_data[0, :],
    exp_data[2, :],
    "s",
    color="black",
    markerfacecolor="none",
    label="T=1475 C",
)
ax2.plot(
    exp_data[0, :],
    exp_data[3, :],
    "o",
    color="black",
    markerfacecolor="none",
    label="T=1510 C",
)

ax2.plot(data["time"][1:] / tscale, deltaP * l_c * 10000)
ax2.set_ylabel("SiC thickness (um)")
ax2.set_xlabel("time (mins)")
ax2.legend(frameon=True)
ax2.set_ylim([0, 15.0])
ax2.set_xlim([0, 350])

fig2.tight_layout()

plt.savefig("D_calibrate_SiC.png")
# plt.savefig("D_experiment.png")

plt.show()
