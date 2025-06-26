import scipy as sc
from scipy.stats import (
    norm,
    beta,
)  # check scipy for whatever distributions is needed for pdf/cdf
import numpy as np


def normal_to_beta(
    mesh_data, typename, norm_mean=1, norm_var=1, a=1, b=1, beta_shift=0, beta_scale=1
):
    data = mesh_data.point_data[typename]

    # convert data to satisfy the new distribution
    cdf_data = norm.cdf(data, loc=norm_mean, scale=norm_var ** (1 / 2))

    update_data = beta.ppf(cdf_data, a, b, loc=beta_shift, scale=beta_scale)

    return update_data


def in_out_region(mesh, region, in_value, out_value):
    X = mesh.points[:, 0]
    Y = mesh.points[:, 1]

    inside_id = np.zeros_like(X, dtype=bool)  # Default: all outside

    if region["shape"] == "circle":
        circle_info = region["info"]
        radius = circle_info[0]
        x_circle = circle_info[1]
        y_circle = circle_info[2]

        # Compute squared distances
        dist_p2 = (X - x_circle) ** 2 + (Y - y_circle) ** 2
        radius_p2 = radius**2

        # Identify points inside or on the circle
        inside_id = dist_p2 <= radius_p2

    # Assign values
    data = np.full_like(X, out_value, dtype=float)
    data[inside_id] = in_value

    return data
