import gstools as gs
import matplotlib.pyplot as plt
import numpy
import meshio
import pandas as pd


##### MESH AND INFO MODIFICATIONS -- NEED TO BE SIMILAR TO MOOSE INPUT FILE
M_C = 12.011 #g/mol
rho_C = 2.26 #g/cc
omega_C = M_C/rho_C
xshift = 3 #cm
yshift = 3 #cm


# import the desirable mesh
mesh = meshio.read("core_in_meltpool.msh")

# generated and plot the random fields on mesh
nfields = 1
porosity = gs.Exponential(dim=2, var=0.002, len_scale=0.1)
srf = gs.SRF(porosity, mean=0.3)

for i in range(nfields):
    srf.mesh(mesh, points="points", name="porosity", seed=135)
    #srf.mesh(mesh, points="centroids", name="porosity", seed=125)

X = mesh.points[:, 0]
Y = mesh.points[:, 1]
Z = mesh.points[:, 2]
data = mesh.point_data["porosity"]
#cell_data = mesh.cell_data["porosity"]

# print(cell_data)
export_points = mesh.points
export_cells = mesh.cells

# print(export_cells)

export_mesh = meshio.Mesh(export_points, export_cells, point_data={"porosity": data})

mesh.write("try.msh", file_format = 'gmsh')

plt.tricontourf(X, Y, data)
plt.colorbar()

plt.xlim([0,10])
plt.ylim([0,10])

plt.savefig("phiC0_alphaC0.png")
#
## save to csv file

df = pd.DataFrame({"x": X+xshift, "y": Y+yshift, "z": Z, "phiC0": data, "alphaC0": data/omega_C})
#df = pd.DataFrame({ "porosity": data})
df.to_csv("phiC0_alphaC0.csv", index=False, header=False)
