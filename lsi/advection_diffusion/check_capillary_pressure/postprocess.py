from matplotlib import pyplot as plt
from matplotlib import colors, cm
import numpy as np
import pandas as pd
from pathlib import Path

out_dir = Path("function2")
plt_dir = Path("function2/plots")
plt_dir.mkdir(exist_ok=True)
nstep = len(list(out_dir.glob("out_value_*.csv")))
summary = pd.read_csv(out_dir / "out.csv")
times = summary["time"]

font = {"family": "monospace"}
fsize = 13
figsize = (5.22, 3.4)
lw = 1

plt.rc("font", size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

van_genutchten_constant = 4e-4

# colormap
norm = colors.Normalize(vmin=times.iloc[0], vmax=times.iloc[-1])
sm = cm.ScalarMappable(norm=norm, cmap="rainbow")

# functional form
fig, ax = plt.subplots(figsize=figsize)

df = pd.read_csv(out_dir / "out.csv")
ax.plot(
    df["Seff"][1:], -df["Pc"][1:] * van_genutchten_constant
)  ##flip for visualization
ax.set_yscale("log")

ax.set_ylabel("Pc*a")
ax.set_xlabel("effective saturation [.]")
fig.tight_layout()
fig.savefig(plt_dir / "capillary_pressure.png")


# check derivatives
fig2, ax2 = plt.subplots(figsize=figsize)

df = pd.read_csv(out_dir / "out.csv")

alpha = np.array(df["alpha"][1:])
Pcnorm = np.array(df["Pc"][1:])

dPc_neml2 = df["dPcdalpha"][1:]

dPc_FD = (Pcnorm[1:] - Pcnorm[:-1]) / (alpha[1:] - alpha[:-1])

ax2.plot(alpha[:-1], dPc_FD, "x", label="Finite Difference")
ax2.plot(alpha[1:], dPc_neml2[1:], label="NEML2_normality")

ax2.set_ylabel("dPc / dalpha")
ax2.set_xlabel("effective saturation [.]")
ax2.legend()
ax2.set_ylim((-0.15e6, 0))

fig2.tight_layout()
fig2.savefig(plt_dir / "check_dPcdalpha.png")


plt.close(fig)
