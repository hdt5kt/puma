import numpy as np
import subprocess
import os

########################################## Input ##############################################
##                                                                                           ##
## Two independent process: reactive infiltration with solid mechanics from fluid swelling   ##
#                   and solidification without fluids flow                                   ##
##                                                                                           ##
###############################################################################################

save_folder = "main"
corenum = 24  # number of cores used for simulation
puma_run_file = "./../../../../../puma-opt"

########################################### mesh info #########################################
meshfile = "gold/SiC_core.msh"

############################# material and reaction properties ################################
##           Current properties are for Si - SiC - C systems                                 ##

# universal constant
gravity = 980.665  # 9.80665  # cm/s2

# denisty # g/cc
rho_Si = 2.570  # density at liquid state
rho_SiC = 3.210
rho_C = 2.260

# Molar Mass # g mol-1
M_Si = 28.085
M_SiC = 40.11
M_C = 12.011

# heat capacity Jkg-1K-1
cp_Si = 710e4
cp_SiC = 550e4
cp_C = 1500e4

# porous flow properties
mu_Si = 0.01  # g-cm-1s-1
perm_ref = 1e-8  # permeability

D_macro = 0.0002 # cm2 s-1
D_macro_high = 0.01 # cm2 s-1
D_macro_low = 0.0002 #0.003 # cm2 s-1

transition_saturation_front = 0.75
transition_saturation_back = 0.45
transition_saturation_back_start = 0.65

# porous flow pressure models properties
brooks_corey_threshold = 0.1e5  # Pa
capillary_pressure_power = 4#10
phi_L_residual = 0.0
permeability_power = 4 #8

# reactive infiltration properties
D_LP = 1.95e-12 # cm2 s-1
l_c = 0.1 # cm
k_C = 1.0
k_SiC = 1.0
chem_p = 250
chem_scale = 700
reactivity_upbound = 0.1
reactivity_lowbound = 0.001

# solidification information
Ts = 1667  # K
Tf = Ts + 60  # K
H_latent = 1787e1  # J/kg
rho_Si_s = 2.370  # density at solid state
swelling_coef = 0.0001

# heat flow properties
kappa_eff = 150e5 # W/mK - thermal conductivity

# thermal expansion coefficients (degree-1)
Tref = 300  # K
g = 1e-6

#### stress-strain ####
E = 400e9 # Pa -- probably be fine 
nu = 0.3

# convection coefficients
htc = 100e5

# heating profiles before reactive infiltration
T0 = Tref  # K - starting and cooling temperatures
Tmax = 1730  # K
dTdt = 10.0  # Ks-1 heating rate
theat = (Tmax - T0) / dTdt
tinfiltrate = 3600  # s
flux_in = 0.005
flux_out = 0.1
run_infiltration = False

# heating profiles during solidification
dTdt_cool = -0.1666  # deg per s
Tfinal = Tref  # K
tcool = (Tmax - Tfinal) / (-dTdt_cool)
twait = 1800

# Simulation parameters
dt = 5
t_ramp = theat + 500

###############################################################################################
##                                                                                           ##
##                                       MAIN                                                ##
##                                                                                           ##
###############################################################################################

print("\n")

# identify the number of rows in initial_condition.csv file
initial_condition_file = "initial_condition.csv"

if not os.path.exists(initial_condition_file):
    raise FileNotFoundError(f"{initial_condition_file} does not exist. Please generate it first.")
with open(initial_condition_file, "r") as f:
    num_rows = sum(1 for line in f)

# num_rows = 100000  # For testing purposes, we set a fixed number of rows

print("Identified {} rows in initial_condition.csv \n".format(num_rows))

print("Starting Infiltration\n")

# run the simulation file infiltration.i, mesh_input.i and initical_condition_from_csv.i
if run_infiltration:
    proc1 = subprocess.Popen(
        [
            "mpiexec",
            "-n",
            str(corenum),
            puma_run_file,
            "-i",
            "infiltration.i",
            "initial_condition_from_csv.i",
            "mesh_input.i",
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
            "D_macro_high={:.16f}".format(D_macro_high),
            "D_macro_low={:.16f}".format(D_macro_low),
            "transition_saturation_front={:.16f}".format(transition_saturation_front),
            "transition_saturation_back={:.16f}".format(transition_saturation_back),
            "transition_saturation_back_start={:.16f}".format(transition_saturation_back_start),
            "chem_p={:.16f}".format(chem_p),
            "chem_scale={:.16f}".format(chem_scale),
            "reactivity_upbound={:.16f}".format(reactivity_upbound),
            "reactivity_lowbound={:.16f}".format(reactivity_lowbound),
            "htc={:.16f}".format(htc),
            "E={:.16f}".format(E),
            "nu={:.16f}".format(nu),
            "therm_expansion={:.16f}".format(g),
            "T0={:.16f}".format(T0),
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
            "num_file_data={}".format(num_rows),
            "meshfile={}".format(meshfile),
        ],
        stdin=subprocess.DEVNULL,
        stdout=open("infiltration.log", "w"),
        stderr=subprocess.STDOUT,
        text=True,
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
        "M_Si={:.16f}".format(M_Si),
        "rho_Si={:.16f}".format(rho_Si),
        "rho_Si_s={:.16f}".format(rho_Si_s),
        "rho_SiC={:.16f}".format(rho_SiC),
        "rho_C={:.16f}".format(rho_C),
        "cp_Si={:.16f}".format(cp_Si),
        "cp_SiC={:.16f}".format(cp_SiC),
        "cp_C={:.16f}".format(cp_C),
        "swelling_coef={:.16f}".format(swelling_coef),
        "meshfile={}".format(meshfile),
        # "--parse-neml2-only",
    ],
    stdin=subprocess.DEVNULL,
    stdout=open("solidification.log", "w"),
    stderr=subprocess.STDOUT,
    text=True,
)
proc2.wait()
