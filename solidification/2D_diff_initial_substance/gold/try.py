import gstools as gs
import matplotlib.pyplot as plt
import numpy
import meshio
import pandas as pd

# import the desirable mesh
mesh = meshio.read("try_mesh.msh")

# generated and plot the random fields on mesh
nfields = 1
porosity = gs.Gaussian(dim=2, var=0.0001, len_scale=0.1)
srf = gs.SRF(porosity, mean=0.05)

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
plt.savefig("porosity.png")
#
## save to csv file
df = pd.DataFrame({"x": X, "y": Y, "z": Z, "porosity": data})
#df = pd.DataFrame({ "porosity": data})
df.to_csv("porosity.csv", index=False, header=False)
