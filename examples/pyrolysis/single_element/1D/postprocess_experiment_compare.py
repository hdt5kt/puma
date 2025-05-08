from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import matplotlib.font_manager as fm
import subprocess

## Experiment Input
exp_dat_list = [
    "experiment_comp/5degpermin_run1.csv",
    "experiment_comp/10degpermin_run1.csv",
    "experiment_comp/20degpermin_run1.csv",
]

col = ["k", "b", "r", "r", "r"]
shape = ["--", "--", "--", "--", "--"]
label = ["5C/min", "10C/min", "20C/min", "20C/min", "20C/min"]

tscale = 60  # seconds to xxx
l_c = 100e-4  # cm

tscale = 60  # division from seconds

## Simulation Input
heating_rate = [5, 10, 20]  # deg per min
col_sim = ["k", "b", "r"]
label_sim = ["5C/min", "10C/min", "20C/min"]
run_simulation = True
Ea = 220820  # J mol-1
A = 1e14  # s-1
corenum = 1  # number of cores used for simulation
puma_run_file = "./../../../../puma-opt"

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/usr/share/fonts/truetype/msttcorefonts/Arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)


## Set up plot ------------------------------------------------------------
font = {"family": "Arial"}
fsize = 13
figsize = (7.2, 4.4)
lw = 1

plt.rc("font", size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize - 1)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

fig, ax = plt.subplots()
fig.set_size_inches(figsize)

## Simulation Main weight fraction ---------------------------------------------------------------------
if run_simulation:
    print("running simulation ...")
    for i in range(len(heating_rate)):
        subprocess.run(
            [
                "mpiexec",
                "-n",
                str(corenum),
                puma_run_file,
                "-i",
                "TGA.i",
                "dTdt={:.9f}".format(heating_rate[i]),
                "Ea={:.9f}".format(Ea),
                "A={:.9f}".format(A),
                "num={}".format(i),
            ]
        )
    print("finish running simulation")

for i in range(len(heating_rate)):
    filename = "simulation/out_" + str(i) + ".csv"
    data = pd.read_csv(filename)
    ax.plot(
        data["temp"][1:],
        (data["ws"][1:] + data["wb"][1:]),
        color=col_sim[i],
        label=label_sim[i],
    )

## Experiment Main weight fraction ---------------------------------------------------------------------
for i in range(len(exp_dat_list)):

    exp_data = pd.read_csv(exp_dat_list[i])
    exp_weightloss = (exp_data["Weight (mg)"]) / exp_data["Weight (mg)"][0]
    ax.plot(
        exp_data["Temperature (degC)"] + 273,
        exp_weightloss,
        shape[i],
        label=label[i],
        ## markersize=1,
        color=col[i],
    )

ax.set(ylabel="weight fraction")
ax.set(xlabel="Temperature (K)")
ax.set_ylim((0.5, 1.05))
ax.set_xlim((300, 1200))


ax.legend(loc="upper right", frameon=False)
fig.tight_layout()  # pad=0.6)
fig.savefig("experiment_fit.png")
plt.show()
