import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
import pandas as pd
import numpy as np

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/home/tranh/Fonts/arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)

font = {"family": "Arial"}
fsize = 12
lw = 1.2

plt.rc("font", **font)
plt.rc("font", **font, size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize clearof the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

colors = ["blue", "red", "black", "purple"]  # Extend as needed
linestyles = ["-", "--", "-.", ":", (0, (3, 1, 1, 1))]  # Custom dash patterns optional
marker = ['o','s','^','p','*','d','v','h','x','+']  # Extend as needed

## Input ------------------------------------------------------------
csv_file = ["exact", "first", "second"]

fig, ax = plt.subplots(figsize=(3.5, 3))

for i in range(len(csv_file)):
    filename = f"{csv_file[i]}.csv"
    data = pd.read_csv(filename)
    time = data['time (s)'].to_numpy()
    thickness = data['thickness (microm)'].to_numpy()
    ax.plot(time, thickness, label=csv_file[i], color=colors[i], linestyle=linestyles[i], linewidth=lw)

ax.set_ylim([0, 10])
ax.set_xlim([0, 60])
ax.set_xlabel("Time (s)")
ax.set_ylabel("Thickness (μm)")
ax.legend()
fig.tight_layout()
fig.savefig(f"compare_order.png", dpi=300)
plt.close(fig)

