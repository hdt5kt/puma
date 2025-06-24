from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import matplotlib.font_manager as fm
import os

## INPUT INFORMATION ------------------------------------------------------

Y_SiC = 7.4e9  # Pa

Y_SiC_compress = -1.1e9  # Pa
Y_SiC_tensions = 0.14e9  # Pa

postprocess_folder = "out"
plotfolder = "results"

filename = [
    "cane_modified_0p05",
    "cane_modified_0p1",
    "cane_modified_0p15",
    "cane_modified_0p2",
    "cane_modified_0p25",
    "cane_modified_0p3",
    "cane_modified_0p35",
    "cane_modified_0p4",
    "cane_modified_0p45",
    "cane_modified_0p5",
    ## split
    "cane_original_0p05",
    "cane_original_0p1",
    "cane_original_0p15",
    "cane_original_0p2",
    "cane_original_0p25",
    "cane_original_0p3",
    "cane_original_0p35",
    "cane_original_0p4",
]

tl = np.array(
    [
        0.05,
        0.1,
        0.15,
        0.2,
        0.25,
        0.3,
        0.35,
        0.4,
        0.45,
        0.5,
        0.05,
        0.1,
        0.15,
        0.2,
        0.25,
        0.3,
        0.35,
        0.4,
    ]
)

seperate = 10

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/usr/share/fonts/truetype/wsttcorefonts/Arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)

font = {"family": "Arial"}
fsize = 14
figsize = (5, 4)
lw = 1

if not os.path.isdir(plotfolder):
    os.mkdir(plotfolder)

plt.rc("font", **font)
plt.rc("font", **font, size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize clearof the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

fig, ax = plt.subplots()
fig.set_size_inches(figsize)

ss = np.zeros(len(filename))

## Results
for i in range(len(filename)):
    fname = os.path.join(postprocess_folder, filename[i] + ".csv")
    data = pd.read_csv(fname)
    maxss = np.max(data["max_pk1_principal"])
    minss = np.min(data["max_pk1_principal"])
    if np.abs(maxss) > np.abs(minss):
        ss[i] = np.max(data["max_pk1_principal"])
    else:
        ss[i] = np.min(data["max_pk1_principal"])
    # ss[i] = data["max_pk1_principal"][-1]

ax.plot(tl[0:seperate] * 10.0, ss[0:seperate] / 1e9, "k", label="modified")
ax.plot(tl[seperate:] * 10.0, ss[seperate:] / 1e9, "--k", label="original")

ax.axhline(y=Y_SiC_compress / 1e9, color="r", linestyle="--")
# ax.axhline(y=Y_SiC_tensions / 1e9, color="r", linestyle="--")

ax.set_xlabel("tl, vertical wall thickness (mm)")
ax.set_ylabel("max principle (GPa)")

# ax.legend()

fig.tight_layout()

fig.savefig(os.path.join(plotfolder, postprocess_folder + ".png"), dpi=300)
