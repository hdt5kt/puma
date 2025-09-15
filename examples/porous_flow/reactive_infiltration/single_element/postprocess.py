from matplotlib import pyplot as plt
from matplotlib import colors, cm
import pandas as pd
from pathlib import Path

lc = 0.01
show_other_components = True

out_dir = Path("output")
plt_dir = Path("plots")
plt_dir.mkdir(exist_ok=True)

exp_data = pd.read_csv("thickness_time_lsi.csv")

data = pd.read_csv(out_dir / "out.csv")

font = {"family": "Arial"}
fsize = 14
figsize = (3.5*1.25, 3*1.25)
lw = 1

plt.rc("font", size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title


fig, ax = plt.subplots(figsize=figsize)

# Experimental data

# Scatter plot for exp_data with key "Time" vs the other keys, now with different markers but the same black color
mlist = ["o", "s", "D", "^", "v", ">", "<"]
i = 0
for key in exp_data.columns[1:]:
    ax.scatter(exp_data["Time"], exp_data[key] * 1e-4 / lc, label=key, s=30, 
               marker=mlist[i], color="black", facecolors="none")
    i += 1

# ax.legend()

# Simulation data
ax.plot(data["time"]/60, data["delta_P"], color="blue", lw=lw+0.2)

ax.set_ylabel("delta/lc")
ax.set_xlabel("time (min)")
#ax.set_xlim(0, 200)

if show_other_components:
    out_dir = Path("output_chemonly")
    data = pd.read_csv(out_dir / "out.csv")
    ax.plot(data["time"]/60, data["delta_P"], "--", color="blue", lw=lw)

    out_dir = Path("output_diffonly")
    data = pd.read_csv(out_dir / "out.csv")
    ax.plot(data["time"]/60, data["delta_P"], ":", color="blue", lw=lw)


#ax.set_ylim(0, 0.125)
fig.tight_layout()


# save figure with 300dpi resolution


fig.savefig("compare_tgt.png", bbox_inches="tight", dpi=300)
