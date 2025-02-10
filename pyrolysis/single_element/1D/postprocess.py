from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
import torch

## Input
filename = "solution1/out.csv"


## Set up plot ------------------------------------------------------------
font = {"family": "monospace"}
fsize = 11
figsize = (8, 6)
lw = 1

plt.rc("font", **font)
plt.rc("font", **font, size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

fig, ax = plt.subplots(2, 2)
fig.set_size_inches(figsize)


## Main ---------------------------------------------------------------------

data = pd.read_csv(filename)

ax[0, 0].plot(data["temp"][1:], data["ms"][1:], label="char", color="red")
ax[0, 0].plot(data["temp"][1:], data["mp"][1:], label="SiC", color="blue")
ax[0, 0].plot(data["temp"][1:], data["mb"][1:], label="PR", color="black")
ax[0, 0].plot(data["temp"][1:], data["mg"][1:], label="gas", color="purple")
ax[0, 0].set(ylabel="pyrolysis mass (kg)")
ax[0, 0].legend(loc="best", frameon=False)

ax[1, 0].plot(data["temp"][1:], data["vs"][1:], label="char", color="red")
ax[1, 0].plot(data["temp"][1:], data["vp"][1:], label="SiC", color="blue")
ax[1, 0].plot(data["temp"][1:], data["vb"][1:], label="PR", color="black")
ax[1, 0].plot(data["temp"][1:], data["vv"][1:], label="void", color="purple")
ax[1, 0].legend(loc="upper right", frameon=False)
ax[1, 0].set(ylabel="element volume fraction")
ax[1, 0].set(xlabel="Temperature (K)")

ax[0, 1].plot(data["temp"][1:], data["ws"][1:], label="char", color="red")
ax[0, 1].plot(data["temp"][1:], data["wp"][1:], label="SiC", color="blue")
ax[0, 1].plot(data["temp"][1:], data["wb"][1:], label="PR", color="black")
ax[0, 1].set(ylabel="element mass fraction")
ax[0, 1].legend(loc="best", frameon=False)

ax[1, 1].plot(data["temp"][1:], data["V"][1:], label="char", color="red")
ax[1, 1].set(ylabel="element total volume (m^3)")
ax[1, 1].set(xlabel="Temperature (K)")


fig.tight_layout()
plt.show()
