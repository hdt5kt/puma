import gstools as gs
import matplotlib.pyplot as plt
import meshio
import pandas as pd
import generate_porosity_utility as util


def normal_to_beta(
    mesh_data, typename, norm_mean=1, norm_var=1, a=1, b=1, beta_shift=0, beta_scale=1
):
    data = mesh_data.point_data[typename]

    # convert data to satisfy the new distribution
    cdf_data = norm.cdf(data, loc=norm_mean, scale=norm_var ** (1 / 2))

    update_data = beta.ppf(cdf_data, a, b, loc=beta_shift, scale=beta_scale)

    return update_data


save_image = "void_fraction.png"
mesh_name = "core.msh"


##### MESH AND INFO MODIFICATIONS -- NEED TO BE SIMILAR TO MOOSE INPUT FILE
rho_C = 2.00  # g/cc
xshift = 0  # cm
yshift = 0  # cm

method = "in_out"  # choices: random, in_out_circle

###### Random field characteristic input
if method == "random":
    beta_a = 2.0
    beta_b = 10.0
    min_porosity = 0.2
    max_porosity = 0.5
    len_scale = 1

###### user provide the region where the value is 'a', else it is 'b'
if method == "in_out":
    region = {
        "shape": "circle",
        "info": [
            2,
            5,
            5,
        ],  # three values for circle: radius, x, y coordinates of the center}
    }
    in_value = 0.8
    out_value = 0.2

# import the desirable mesh
mesh = meshio.read(mesh_name)
X = mesh.points[:, 0]
Y = mesh.points[:, 1]
Z = mesh.points[:, 2]

####################### ------------- MAIN -------------- #######################


if method == "random":
    # generated and plot the random fields on mesh
    nfields = 1
    porosity = gs.Exponential(dim=2, var=1, len_scale=len_scale)
    srf = gs.SRF(porosity, mean=1.0)

    for i in range(nfields):
        srf.mesh(mesh, points="points", name="porosity", seed=135)
        # srf.mesh(mesh, points="centroids", name="porosity", seed=125)

    data = util.normal_to_beta(
        mesh,
        "porosity",
        norm_mean=1,
        norm_var=1,
        b=beta_b,
        a=beta_a,
        beta_shift=min_porosity,
        beta_scale=(max_porosity - min_porosity),
    )

if method == "in_out":
    data = util.in_out_region(
        mesh,
        region,
        in_value,
        out_value,
    )

####################### -------- PLOTTING AND SAVE DATA ------- ##################

plt.tricontourf(X, Y, data)
plt.colorbar()
plt.savefig(save_image)
#
## save to csv file

df = pd.DataFrame({"x": X + xshift, "y": Y + yshift, "z": Z, "void": data})
# df = pd.DataFrame({ "porosity": data})
df.to_csv("void.csv", index=False, header=False)
