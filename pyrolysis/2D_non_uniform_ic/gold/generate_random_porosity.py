import gstools as gs
import matplotlib.pyplot as plt
from matplotlib import colors, cm
import matplotlib.font_manager as fm
import numpy as np
import meshio
import pandas as pd

## Set up plot ------------------------------------------------------------
fe = fm.FontEntry(
    fname="/usr/share/fonts/truetype/msttcorefonts/Arial.ttf", name="Arial"
)
fm.fontManager.ttflist.insert(0, fe)

font = {"family": "Arial"}
fsize = 15
figsize = (4.83 * 1.2, 5.15 * 1.4)
lw = 1

##### MESH AND INFO MODIFICATIONS -- NEED TO BE SIMILAR TO MOOSE INPUT FILE
xshift = 0  # cm
yshift = 0  # cm


# import the desirable mesh
mesh = meshio.read("mesh_part.msh")

# generated and plot the random fields on mesh
nfields = 1
binder_mass = gs.Exponential(dim=2, var=4, len_scale=0.1)
srf_binder = gs.SRF(binder_mass, mean=24)

particle_mass = gs.Exponential(dim=2, var=6, len_scale=0.1)
srf_particle = gs.SRF(particle_mass, mean=25)

for i in range(nfields):
    srf_binder.mesh(mesh, points="points", name="binder_mass", seed=135)
    srf_particle.mesh(mesh, points="points", name="particle_mass", seed=223)
    # srf.mesh(mesh, points="centroids", name="porosity", seed=125)

X = mesh.points[:, 0]
Y = mesh.points[:, 1]
Z = mesh.points[:, 2]
data_binder = mesh.point_data["binder_mass"]
data_particle = mesh.point_data["particle_mass"]
data_gas = 1e-4 * np.ones_like(data_binder)
data_solid = 3 * np.ones_like(data_binder)
vv0 = 0.0001 * np.ones_like(data_binder)

##  denisty kgm-3
rho_s = 2260
rho_b = 1250
rho_g = 1
rho_p = 3210

ms0 = data_solid
mb0 = data_binder
mp0 = data_particle
mg0 = data_gas

data_void = vv0 / (1 - vv0) * (ms0 / rho_s + mb0 / rho_b + mp0 / rho_p)
data_volume = ms0 / rho_s + mb0 / rho_b + mp0 / rho_p + data_void

## PLOTTING

fsize = 13

figsize = (4.5 * 2, 3.3 * 2)

plt.rc("font", **font)
plt.rc("font", **font, size=fsize)  # controls default text sizes
plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
plt.rc("legend", fontsize=fsize)  # legend fontsize
plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

fig, axs = plt.subplots(1, 2, figsize=figsize)

h1 = axs[0].tricontourf(X, Y, data_binder)
h2 = axs[1].tricontourf(X, Y, data_particle)

fig.colorbar(h1)
fig.colorbar(h2)

fig.tight_layout()
# plt.xlim([0, 10])
# plt.ylim([0, 10])

plt.savefig("check_init.png")
#
## save to csv file

df = pd.DataFrame(
    {
        "x": X + xshift,
        "y": Y + yshift,
        "z": Z,
        "binder": data_binder,
        "particle": data_particle,
        "solid": data_solid,
        "gas": data_gas,
        "void_volume": data_void,
        "volume": data_volume,
    }
)
# df = pd.DataFrame({ "porosity": data})
df.to_csv("initial_mass.csv", index=False, header=False)
