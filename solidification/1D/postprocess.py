from matplotlib import pyplot as plt
from matplotlib import colors, cm
import pandas as pd
import numpy as np
import torch
import os

## Input
basefolder = "checkqdot/"
plotfolder = "plot_checkqdot"

if not os.path.isdir(plotfolder):
    os.mkdir(plotfolder)

postdata = pd.read_csv(basefolder + "out.csv")
times = postdata["time"]

tscale = 3600 #division from seconds

## Set up plot ------------------------------------------------------------
font = {"family": "monospace"}
fsize = 11
figsize = (10, 3)
lw = 1

norm = colors.Normalize(vmin=times.iloc[0]/tscale, vmax=times.iloc[-1]/tscale)
sm = cm.ScalarMappable(norm=norm, cmap="rainbow")

### Main ---------------------------------------------------------------------

id = ["result"]
idlist = [["T", "f_Si_solid", "qdot"]]
idy = [["temperature (K)","fraction of solid Si","heat release rate (J/mol-s)"]]

for keyid in range(len(id)):
    plt.rc("font", **font)
    plt.rc("font", **font, size=fsize)  # controls default text sizes
    plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
    plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
    plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
    plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
    plt.rc("legend", fontsize=fsize)  # legend fontsize
    plt.rc("figure", titlesize=fsize)  # fontsize of the figure title
    
    fig, ax = plt.subplots(1, 3)
    fig.set_size_inches(figsize)
    
    for i in range(1,100000):
        filename = basefolder + "out_line_{:04d}.csv".format(i)
        if not os.path.isfile(filename):
            break
        data = pd.read_csv(filename)

        ax[0].plot(data["x"], data[idlist[keyid][0]], color=sm.to_rgba(times.iloc[i]/tscale))        
        ax[0].set(ylabel= idy[keyid][0])
        ax[0].set(xlabel = "x (m)")

        ax[1].plot(data["x"], data[idlist[keyid][1]], color=sm.to_rgba(times.iloc[i]/tscale))        
        ax[1].set(ylabel= idy[keyid][1])
        ax[1].set(xlabel = "x (m)")

        ax[2].plot(data["x"], data[idlist[keyid][2]], color=sm.to_rgba(times.iloc[i]/tscale))        
        ax[2].set(ylabel= idy[keyid][2])
        ax[2].set(xlabel = "x (m)")

    fig.tight_layout(w_pad=2.8)
    cbar_ax = fig.add_axes([0.9, 0.12, 0.02, 0.8]) 
    fig.subplots_adjust(right=0.88)
    fig.colorbar(sm, cax = cbar_ax, label="time [hrs]", aspect = 100, fraction = 0.5)

    fig.savefig(plotfolder + "/{}.png".format(id[keyid]))
    plt.close(fig)
