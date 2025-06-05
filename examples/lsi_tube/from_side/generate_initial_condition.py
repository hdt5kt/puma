import gstools as gs
import matplotlib.pyplot as plt
from matplotlib import colors, cm
import matplotlib.font_manager as fm
import numpy as np
import meshio
import pandas as pd
import os
import scipy as sc
from scipy.stats import (
    norm,
    beta,
)  # check scipy for whatever distributions is needed for pdf/cdf

# currently only for two phase systems
# sampling C phase then sampling the proportion for the non-reactive phase


def generate_initial_conditions(
    meshfile,
    len_scale,
    min_solid=1e-4,
    max_solid=1,
    beta_a_solid=2.0,
    beta_b_solid=10.0,
    seed_solid=4562,
    min_fraction_noreact=1e-4,
    max_fraction_noreact=0.3,
    beta_a_fraction_noreact=2.0,
    beta_b_fraction_noreact=10.0,
    seed_fraction_noreact=4472,
    plot_cond=True,
):
    assert min_solid < max_solid
    assert min_solid >= 0 and min_solid <= 1
    assert max_solid >= 0 and max_solid <= 1

    assert min_fraction_noreact < max_fraction_noreact
    assert min_fraction_noreact >= 0 and min_fraction_noreact <= 1
    assert max_fraction_noreact >= 0 and max_fraction_noreact <= 1

    beta_shift_solid = min_solid
    beta_scale_solid = max_solid - min_solid

    beta_shift_fraction_noreact = min_fraction_noreact
    beta_scale_fraction_noreact = max_fraction_noreact - min_fraction_noreact

    # import the desirable mesh
    mesh = meshio.read(meshfile)

    # generated the random fields on mesh
    solid_info = gs.Exponential(dim=2, var=1, len_scale=len_scale)
    srf_solid = gs.SRF(solid_info, mean=1)

    srf_solid.mesh(mesh, points="points", name="solid_info", seed=seed_solid)

    update_solid_info = normal_to_beta(
        mesh,
        "solid_info",
        norm_mean=1,
        norm_var=1,
        b=beta_b_solid,
        a=beta_a_solid,
        beta_shift=beta_shift_solid,
        beta_scale=beta_scale_solid,
    )

    left_over = 1.0 - update_solid_info

    # generated the random fields on mesh
    noreact_percent_info = gs.Exponential(dim=2, var=1, len_scale=len_scale)
    srf_noreact = gs.SRF(noreact_percent_info, mean=1)

    srf_noreact.mesh(
        mesh, points="points", name="noreact_info", seed=seed_fraction_noreact
    )

    update_noreactpercent_info = normal_to_beta(
        mesh,
        "noreact_info",
        norm_mean=1,
        norm_var=1,
        b=beta_b_fraction_noreact,
        a=beta_a_fraction_noreact,
        beta_shift=beta_shift_fraction_noreact,
        beta_scale=beta_scale_fraction_noreact,
    )

    update_noreact_info = update_noreactpercent_info * left_over

    X = mesh.points[:, 0]
    Y = mesh.points[:, 1]
    Z = mesh.points[:, 2]

    df = pd.DataFrame(
        {
            "x": X,
            "y": Y,
            "z": Z,
            "solid": update_solid_info,
            "noreact": update_noreact_info,
        }
    )
    df.to_csv("initial_condition.csv", index=False, header=False)

    if plot_cond:
        plot_check(X, Y, update_solid_info, update_noreact_info, "initial_condition")

    return df


def normal_to_beta(
    mesh_data, typename, norm_mean=1, norm_var=1, a=1, b=1, beta_shift=0, beta_scale=1
):
    data = mesh_data.point_data[typename]

    # convert data to satisfy the new distribution
    cdf_data = norm.cdf(data, loc=norm_mean, scale=norm_var ** (1 / 2))

    update_data = beta.ppf(cdf_data, a, b, loc=beta_shift, scale=beta_scale)

    return update_data


def plot_check(X, Y, data_solid, data_noreact, fname):
    fsize = 12
    ## Set up plot ------------------------------------------------------------
    fe = fm.FontEntry(
        fname="/usr/share/fonts/truetype/msttcorefonts/Arial.ttf", name="Arial"
    )
    fm.fontManager.ttflist.insert(0, fe)

    font = {"family": "Arial"}
    fsize = 15
    figsize = (4.83 * 2, 2.1 * 2)
    lw = 1
    # plt.rc("font", **font)
    plt.rc("font", size=fsize)  # controls default text sizes
    plt.rc("axes", titlesize=fsize)  # fontsize of the axes title
    plt.rc("axes", labelsize=fsize)  # fontsize of the x and y labels
    plt.rc("xtick", labelsize=fsize)  # fontsize of the tick labels
    plt.rc("ytick", labelsize=fsize)  # fontsize of the tick labels
    plt.rc("legend", fontsize=fsize)  # legend fontsize
    plt.rc("figure", titlesize=fsize)  # fontsize of the figure title

    fig, axs = plt.subplots(1, 2, figsize=figsize)

    h1 = axs[0].tricontourf(X, Y, data_solid)
    h2 = axs[1].tricontourf(X, Y, data_noreact)

    fig.colorbar(h1)
    fig.colorbar(h2)

    fig.tight_layout()
    # plt.xlim([0, 10])
    # plt.ylim([0, 10])

    if not os.path.exists("check_init"):
        os.makedirs("check_init")

    plt.savefig("check_init/" + fname + ".png")
    pass
