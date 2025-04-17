import gstools as gs
import matplotlib.pyplot as plt
import numpy
import meshio
import pandas as pd
import scipy as sc
from scipy.stats import (
    norm,
    beta,
)  # check scipy for whatever distributions is needed for pdf/cdf


def normal_to_beta(
    mesh_data, typename, norm_mean=1, norm_var=1, a=1, b=1, beta_shift=0, beta_scale=1
):
    data = mesh_data.point_data[typename]

    # convert data to satisfy the new distribution
    cdf_data = norm.cdf(data, loc=norm_mean, scale=norm_var ** (1 / 2))

    update_data = beta.ppf(cdf_data, a, b, loc=beta_shift, scale=beta_scale)

    return update_data


##### MESH AND INFO MODIFICATIONS -- NEED TO BE SIMILAR TO MOOSE INPUT FILE
M_C = 12.011  # g/mol
rho_C = 2.26  # g/cc
omega_C = M_C / rho_C
xshift = 3  # cm
yshift = 3  # cm

###### Random field characteristic input
beta_a = 2.0
beta_b = 10.0
min_porosity = 0.7
max_porosity = 0.9

len_scale = 0.2

# import the desirable mesh
mesh = meshio.read("core_in_meltpool.msh")

# generated and plot the random fields on mesh
nfields = 1
porosity = gs.Exponential(dim=2, var=1, len_scale=len_scale)
srf = gs.SRF(porosity, mean=1.0)

for i in range(nfields):
    srf.mesh(mesh, points="points", name="porosity", seed=135)
    # srf.mesh(mesh, points="centroids", name="porosity", seed=125)

X = mesh.points[:, 0]
Y = mesh.points[:, 1]
Z = mesh.points[:, 2]

data = normal_to_beta(
    mesh,
    "porosity",
    norm_mean=1,
    norm_var=1,
    b=beta_b,
    a=beta_a,
    beta_shift=min_porosity,
    beta_scale=(max_porosity - min_porosity),
)

plt.tricontourf(X, Y, data)
plt.colorbar()

plt.xlim([0, 10])
plt.ylim([0, 10])

plt.savefig("phiC0_alphaC0.png")
#
## save to csv file

df = pd.DataFrame(
    {"x": X + xshift, "y": Y + yshift, "z": Z, "phiC0": data, "alphaC0": data / omega_C}
)
# df = pd.DataFrame({ "porosity": data})
df.to_csv("phiC0_alphaC0.csv", index=False, header=False)
