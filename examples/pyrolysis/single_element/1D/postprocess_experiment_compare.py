from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import matplotlib.font_manager as fm
from scipy import integrate

## Input
filename = "experiment_comp/out.csv"
exp_dat_list = [
    "experiment_comp/20degpermin_run1.csv",
    "experiment_comp/20degpermin_run2.csv",
]
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
fsize = 13
figsize = (4.2, 3.4)
lw = 1

plt.rc("font", size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize - 1)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title


## Main weight fraction ---------------------------------------------------------------------

fig, ax = plt.subplots()
fig.set_size_inches(figsize)

for i in range(len(exp_dat_list)):

    exp_data = pd.read_csv(exp_dat_list[i])
    exp_weightloss = (exp_data["Weight (mg)"]) / exp_data["Weight (mg)"][0]
    ax.plot(
        exp_data["Temperature (degC)"] + 273,
        exp_weightloss,
        "x",
        label="experiment %d" % i,
        markersize=1,
    )

data = pd.read_csv(filename)
ax.plot(
    data["temp"][1:],
    (data["ws"][1:] + data["wb"][1:]),
    color="black",
    label="kinetic model",
)
ax.set(ylabel="weight fraction")
ax.set(xlabel="Temperature (K)")
ax.set_ylim((0.5, 1.05))
ax.set_xlim((250, 1500))


ax.legend(loc="upper right", frameon=False)
fig.tight_layout()  # pad=0.6)
fig.savefig("experiment_fit.png")
# plt.show()


## Main Heat Flow ---------------------------------------------------------------------

fig2, ax2 = plt.subplots()
fig2.set_size_inches(figsize)

time_cut = [1243, 1430]
shift = [0, 0]  # [-4.5, -6.5]

for i in range(len(exp_dat_list)):
    exp_data = pd.read_csv(exp_dat_list[i])
    heat_flow = exp_data["Heat Flow (mW)"]
    # ax2.plot(exp_data["Temperature (degC)"] + 273, heat_flow)
    ax2.plot(
        exp_data["Time (min)"] * 60,
        heat_flow / exp_data["Weight (mg)"][0] - shift[i],
        label="experiment %d" % i,
    )

    heat_flow = (
        integrate.trapezoid(
            exp_data["Time (min)"][exp_data["Temperature (degC)"] < time_cut[i]] * 60,
            exp_data["Heat Flow (mW)"][exp_data["Temperature (degC)"] < time_cut[i]]
            - shift[i],
        )
        / exp_data["Weight (mg)"][0]
    )
    # print(heat_flow)

ax2.set_xlim((0, 3000))
ax2.set_ylim((-3, 1))

ax2.set(ylabel="Heat Release ( J/(s-g) )")
ax2.set(xlabel="Time (s)")

ax2.legend(loc="upper right", frameon=False)
fig2.tight_layout()  # pad=0.6)
fig2.savefig("Heat flow.png")

# plt.show()
