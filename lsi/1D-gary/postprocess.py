from matplotlib import pyplot as plt
from matplotlib import colors, cm
import pandas as pd
from pathlib import Path

out_dir = Path("results")
plt_dir = Path("plots")
plt_dir.mkdir(exist_ok=True)
nstep = len(list(out_dir.glob("out_value_*.csv")))
summary = pd.read_csv(out_dir / "out.csv")
times = summary["time"]

# colormap
norm = colors.Normalize(vmin=times.iloc[0], vmax=times.iloc[-1])
sm = cm.ScalarMappable(norm=norm, cmap="viridis")

qois = ["alpha", "phi_Si", "phi_C", "phi_SiC", "phi_0", "alpha_Si", "alpha_C"]

for qoi in qois:
    fig, ax = plt.subplots(figsize=(8, 5))
    for i in range(nstep):
        df = pd.read_csv(out_dir / "out_value_{:04d}.csv".format(i))
        ax.plot(df["x"], df[qoi], color=sm.to_rgba(times.iloc[i]))
    fig.colorbar(sm, ax=ax, label="Time [s]")
    fig.tight_layout()
    fig.savefig(plt_dir / "{}.png".format(qoi))
    plt.close(fig)
