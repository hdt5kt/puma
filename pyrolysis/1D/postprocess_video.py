from matplotlib import pyplot as plt
from matplotlib import colors, cm
import matplotlib.font_manager as fm
import pandas as pd
import numpy as np
import torch
import os

## Input
basefolder = "example_1D/"
plotfolder = "plot_example_1D/sequence"

if not os.path.isdir(plotfolder):
    os.mkdir(plotfolder)

postdata = pd.read_csv(basefolder + "out.csv")
times = postdata["time"]

tscale = 3600  # division from seconds

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/usr/share/fonts/truetype/msttcorefonts/Arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)

font = {"family": "Arial"}
fsize = 15
figsize = (4.83 * 1.2, 5.15 * 1.4)
lw = 1

norm = colors.Normalize(vmin=times.iloc[0] / tscale, vmax=times.iloc[-1] / tscale)
sm = cm.ScalarMappable(norm=norm, cmap="rainbow")

### Main ---------------------------------------------------------------------

id = ["temp_mass"]
idlist = [["T", "wb", "ws", "phiop"]]
idy = [["temperature (K)", "weight fraction", "open pore volume fraction"]]


for keyid in range(len(id)):
    plt.rc("font", **font)
    plt.rc("font", **font, size=fsize)  # controls default text sizes
    plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
    plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
    plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
    plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
    plt.rc("legend", fontsize=fsize)  # legend fontsize
    plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

    for i in range(1, 100000):
        fig, ax = plt.subplots(3, 1)
        fig.set_size_inches(figsize)

        filename = basefolder + "out_line_{:04d}.csv".format(i)
        if not os.path.isfile(filename):
            break
        data = pd.read_csv(filename)

        ax[0].plot(
            data["x"],
            data[idlist[keyid][0]],
            color="black",
            linewidth=2.0,
        )  # sm.to_rgba(times.iloc[i] / tscale))
        ax[0].set(ylabel=idy[keyid][0])
        # ax[0].set(xlabel="x (m)")
        ax[0].set_ylim([300, 1010])
        ax[0].plot(data["x"], 1687 * np.ones_like(data["x"]), "--b")

        ax[1].plot(
            data["x"],
            data[idlist[keyid][1]],
            "--",
            color="black",
            linewidth=2.0,
            label="binder",
        )  # sm.to_rgba(times.iloc[i] / tscale))

        ax[1].plot(
            data["x"],
            data[idlist[keyid][2]],
            color="black",
            linewidth=2.0,
            label="solid",
        )  # sm.to_rgba(times.iloc[i] / tscale))
        ax[1].set(ylabel=idy[keyid][1])
        ax[1].set_ylim([-0.01, 0.5])
        ax[1].legend(loc="center right")

        ax[2].plot(
            data["x"],
            data[idlist[keyid][3]],
            color="black",
            linewidth=2.0,
        )  # sm.to_rgba(times.iloc[i] / tscale))
        ax[2].set(ylabel=idy[keyid][2])
        ax[2].set(xlabel="x")
        ax[2].set_ylim([0.032, 0.042])

        fig.tight_layout()  # w_pad=2.8)
        # cbar_ax = fig.add_axes([0.9, 0.12, 0.02, 0.8])
        # fig.subplots_adjust(right=0.88)
        # fig.colorbar(sm, cax=cbar_ax, label="time [hrs]", aspect=100, fraction=0.5)

        fig.savefig(plotfolder + "/{:04d}.png".format(i))
        plt.close(fig)
