import numpy as np
import subprocess
import os
from generate_initial_condition import generate_initial_conditions

########################################## Input ##############################################
##                                                                                           ##
## Two independent process: reactive infiltration with solid mechanics from fluid swelling   ##
#                   and solidification without fluids flow                                   ##
##                                                                                           ##
###############################################################################################

save_folder = "main"
corenum = 22  # number of cores used for simulation
puma_run_file = "./../../puma-opt"

########################### parts and geometry information ####################################
# geometry
mesh_file = "gold/design03.exo"

# initial conditions, assumed a binary system at the begining
min_solid = 0.2
max_solid = 0.6
min_SiCbeta_fraction = 0.2
max_SiCbeta_fraction = 0.4
lc = 0.002

############################# material and reaction properties ################################
##           Current properties are for Si - SiC - C systems                                 ##

# universal constant
gravity = 0.0 #9.8  # 9.80665  # m/s2

# denisty # kg/m3
rho_Si = 2570  # density at liquid state
rho_SiC = 3210
rho_C = 2260

# Molar Mass # kg mol-1
M_Si = 0.028085
M_SiC = 0.04011
M_C = 0.012011

# heat capacity Jkg-1K-1
cp_Si = 710
cp_SiC = 550
cp_C = 1500

# porous flow properties
mu_Si = 2.0  # Pa-s
perm_ref = 2e-10  # permeability
D_macro = 1e-6  # m2 s-1

# porous flow pressure models properties
brooks_corey_threshold = 1e6  # Pa
capillary_pressure_power = 3
phi_L_residual = 0.0
permeability_power = 3

# reactive infiltration properties
D_LP = 2.65e-10  # m2 s-1
l_c = 0.01  # m
k_C = 1.0  # chemical reaction constant
k_SiC = 1.0  # chemical reaction constant

# solidification information
Ts = 1687  # K
Tf = Ts + 60  # K
H_latent = 5.0555e3  # egs/mol
rho_Si_s = 2370  # density at solid state
swelling_coef = 1e-2

# heat flow properties
kappa_eff = 50  # W/mK - thermal conductivity

# thermal expansion coefficients (degree-1)
Tref = 300  # K
g = 4e-6

#### stress-strain ####
E = 400e9
nu = 0.3
advs_coefficient = 1e-6

# convection coefficients - Wm-2K
htc = 50

# heating profiles before reactive infiltration
T0 = Tref  # K - starting and cooling temperatures
Tmax = 1730  # K
dTdt = 2.0  # Ks-1 heating rate
theat = (Tmax - T0) / dTdt
tinfiltrate = 3600  # s
flux_in = 0.05
flux_out = 0.05
run_infiltration = True

# heating profiles during solidification
dTdt_cool = -1.0  # deg per s
tcool = (Tmax - T0) / (-dTdt_cool)
twait = 1800

# Simulation parameters
dt = 5
t_ramp = theat + 500

###############################################################################################
##                                                                                           ##
##                                       MAIN                                                ##
##                                                                                           ##
###############################################################################################

# generate the initial conditions
intial_condition = generate_initial_conditions(
    mesh_file,
    lc,
    min_solid=min_solid,
    max_solid=max_solid,
    beta_a_solid=2.0,
    beta_b_solid=5.0,
    seed_solid=4562,
    min_fraction_noreact=min_SiCbeta_fraction,
    max_fraction_noreact=max_SiCbeta_fraction,
    beta_a_fraction_noreact=2.0,
    beta_b_fraction_noreact=5.0,
    seed_fraction_noreact=4472,
    plot_cond=True,
)

num_file_data = len(intial_condition["z"])

print("\n")

print("Starting Infiltration")


# run the simulation file infiltration.i and initical_condition_from_csv.i
if run_infiltration:
    proc1 = subprocess.Popen(
        [
            "mpiexec",
            "-n",
            str(corenum),
            puma_run_file,
            "-i",
            "infiltration.i",
            "mesh_input.i",
            "initial_condition_from_csv.i",
            "dt={:.16f}".format(dt),
            "total_time={:.16f}".format(t_ramp + tinfiltrate),
            "flux_in={:.16f}".format(flux_in),
            "flux_out={:.16f}".format(flux_out),
            "t_ramp={:.16f}".format(t_ramp),
            "t_heat={:.16f}".format(theat),
            "dTdt={:.16f}".format(dTdt),
            "brooks_corey_threshold={:.16f}".format(brooks_corey_threshold),
            "capillary_pressure_power={:.16f}".format(capillary_pressure_power),
            "phi_L_residual={:.16f}".format(phi_L_residual),
            "permeability_power={:.16f}".format(permeability_power),
            "mu_Si={:.16f}".format(mu_Si),
            "perm_ref={:.16f}".format(perm_ref),
            "hf={:.16f}".format(1),
            "kappa_eff={:.16f}".format(kappa_eff),
            "D_macro={:.16f}".format(D_macro),
            "htc={:.16f}".format(htc),
            "E={:.16f}".format(E),
            "nu={:.16f}".format(nu),
            "therm_expansion={:.16f}".format(g),
            "T0={:.16f}".format(T0),
            "advs_coefficient={:.16f}".format(advs_coefficient),
            "meshfile={}".format(mesh_file),
            "gravity={:.16f}".format(gravity),
            "D_LP={:.16f}".format(D_LP),
            "l_c={:.16f}".format(l_c),
            "M_Si={:.16f}".format(M_Si),
            "M_SiC={:.16f}".format(M_SiC),
            "M_C={:.16f}".format(M_C),
            "rho_Si={:.16f}".format(rho_Si),
            "rho_SiC={:.16f}".format(rho_SiC),
            "rho_C={:.16f}".format(rho_C),
            "cp_Si={:.16f}".format(cp_Si),
            "cp_SiC={:.16f}".format(cp_SiC),
            "cp_C={:.16f}".format(cp_C),
            "k_C={:.16f}".format(k_C),
            "k_SiC={:.16f}".format(k_SiC),
            "swelling_coef={:.16f}".format(swelling_coef),
            "num_file_data={:.16f}".format(num_file_data),
            # "--parse-neml2-only",
        ],
        stdin=subprocess.DEVNULL,
        stdout=open("infiltration.log", "w"),
        stderr=subprocess.STDOUT,
        text=True,
        preexec_fn=os.setpgrp 
    )
    proc1.wait()

print("\n")

print("Starting Solidification")

proc2 = subprocess.Popen(
    [
        "mpiexec",
        "-n",
        str(corenum),
        puma_run_file,
        "-i",
        "solidification.i",
        "mesh_input.i",
        "initial_condition_from_exodus.i",
        "dt={:.16f}".format(dt),
        "total_time={:.16f}".format(tcool + twait),
        "t_ramp={:.16f}".format(tcool),
        "dTdt={:.16f}".format(dTdt_cool),
        "kappa_eff={:.16f}".format(kappa_eff),
        "htc={:.16f}".format(htc),
        "E={:.16f}".format(E),
        "nu={:.16f}".format(nu),
        "therm_expansion={:.16f}".format(g),
        "T0={:.16f}".format(Tmax),
        "Tref={:.16f}".format(Tref),
        "Ts={:.16f}".format(Ts),
        "Tf={:.16f}".format(Tf),
        "H_latent={:.16f}".format(H_latent),
        "advs_coefficient={:.16f}".format(advs_coefficient),
        "meshfile={}".format(mesh_file),
        "M_Si={:.16f}".format(M_Si),
        "rho_Si={:.16f}".format(rho_Si),
        "rho_Si_s={:.16f}".format(rho_Si_s),
        "rho_SiC={:.16f}".format(rho_SiC),
        "rho_C={:.16f}".format(rho_C),
        "cp_Si={:.16f}".format(cp_Si),
        "cp_SiC={:.16f}".format(cp_SiC),
        "cp_C={:.16f}".format(cp_C),
        "swelling_coef={:.16f}".format(swelling_coef),
        # "--parse-neml2-only",
    ],
    stdin=subprocess.DEVNULL,
    stdout=open("solidification.log", "w"),
    stderr=subprocess.STDOUT,
    text=True,
    preexec_fn=os.setpgrp 
    )
proc2.wait()
