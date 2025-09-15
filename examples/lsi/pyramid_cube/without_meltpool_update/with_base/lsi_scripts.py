import numpy as np
import subprocess
import os
import time

start_time = time.perf_counter()

########################################## Input ##############################################
##                                                                                           ##
## Two independent process: reactive infiltration with solid mechanics from fluid swelling   ##
#                   and solidification without fluids flow                                   ##
##                                                                                           ##
###############################################################################################

save_folder = "main"
corenum = 24  # number of cores used for simulation
puma_run_file = "./../../../../../puma-opt"

################################## mesh and initial cond info #########################################
meshfile = "gold/SiC_core_dense.msh"
initial_condition_file = "initial_condition_dense.csv"
mesh_scale = 100 # apply scale to mesh

C_ratio = 0.2
phif_min = 0.0001

############################# material and reaction properties ################################
##           Current properties are for Si - SiC - C systems                                 ##

# universal constant
gravity = 980.664 # cm/s2

# denisty # g/cc
rho_Si = 2.570  # density at liquid state
rho_SiC = 3.210
rho_C = 2.260

# Molar Mass # g mol-1
M_Si = 28.085
M_SiC = 40.11
M_C = 12.011

# heat capacity egs g K
cp_Si = 705e4
cp_SiC = 690e4
cp_C = 1500e4

# porous flow properties
mu_Si = 0.01  # g-cm-1s-1
perm_ref = 1e-8  # permeability

D_macro = 0.0002 # cm2 s-1
D_macro_high = 0.001 # cm2 s-1
D_macro_low = 0.0002 #0.003 # cm2 s-1

transition_saturation_front = 0.75
transition_saturation_back = 0.45
transition_saturation_back_start = 0.65

# porous flow pressure models properties
brooks_corey_threshold = 0.1e5  # Pa
capillary_pressure_power = 4
phi_L_residual = 0.0
permeability_power = 4

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
Tf = Ts + 40  # K
H_latent = 1.787e9  # erg/g
rho_Si_s = 2.370  # g/cc
cp_Si_s = 500e4 # erg/g/K
kappa_Si_s = 140e5 # erg/cm/s/K
solidification_rate = 0.002

# heat flow properties # erg cm-1 s-1 K-1
kappa_Si = 148e5
kappa_SiC = 120e5
kappa_C = 300e5

# thermal expansion coefficients (degree-1)
Tref = 300  # K
g = 2.3e-6

#### stress-strain ####
E = 400e9 # Pa -- probably be fine 
nu = 0.3
overflow_Stransition_start = -1.2
overflow_Stransition_end = 0.9
overflow_Stransition_magnitude = 1e6

# convection coefficients
htc = 2.5e5

# heating profiles before reactive infiltration
T0 = Tref  # K - starting and cooling temperatures
Tmax = 1720  # K
dTdt = 1.0  # Ks-1 heating rate
theat = (Tmax - T0) / dTdt
tinfiltrate = 7200  # s
flux_in = 0.05
flux_out = 0.1
run_infiltration = False

# heating profiles during solidification
dTdt_cool = -1  # deg per s
Tfinal = Tref  # K
tcool = (Tmax - Tfinal) / (-dTdt_cool)
twait = 7200

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

if not os.path.exists(initial_condition_file):
    raise FileNotFoundError(f"{initial_condition_file} does not exist. Please generate it first.")
with open(initial_condition_file, "r") as f:
    num_rows = sum(1 for line in f)

# delete the initial_condition.csv file if exist
if os.path.exists("initial_condition.csv"):
    os.remove("initial_condition.csv")


# read the initial_condition_file, apply mesh_scale to the first three columes, 
with open(initial_condition_file, "r") as f:
    lines = f.readlines()
with open("initial_condition.csv", "w") as f:
    for line in lines:
        # Scale the values in the first three columns, keep the other columens the same
        values = line.strip().split(",")
        scaled_values = [str(float(x) * mesh_scale) for x in values[:3]]
        f.write(",".join(scaled_values + values[3:]) + "\n")

# num_rows = 100000  # For testing purposes, we set a fixed number of rows

print("Identified {} rows in the initial condition file \n".format(num_rows))

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
            "initial_condition_from_csv_v2.i",
            "mesh_input.i",
            "dt={:.18f}".format(dt),
            "total_time={:.18f}".format(t_ramp + tinfiltrate),
            "flux_in={:.18f}".format(flux_in),
            "flux_out={:.18f}".format(flux_out),
            "t_ramp={:.18f}".format(t_ramp),
            "t_heat={:.18f}".format(theat),
            "dTdt={:.18f}".format(dTdt),
            "brooks_corey_threshold={:.18f}".format(brooks_corey_threshold),
            "capillary_pressure_power={:.18f}".format(capillary_pressure_power),
            "phi_L_residual={:.18f}".format(phi_L_residual),
            "permeability_power={:.18f}".format(permeability_power),
            "mu_Si={:.18f}".format(mu_Si),
            "perm_ref={:.18f}".format(perm_ref),
            "hf={:.18f}".format(1),
            "kappa_Si={:.18f}".format(kappa_Si),
            "kappa_SiC={:.18f}".format(kappa_SiC),
            "kappa_C={:.18f}".format(kappa_C),
            "D_macro={:.18f}".format(D_macro),
            "D_macro_high={:.18f}".format(D_macro_high),
            "D_macro_low={:.18f}".format(D_macro_low),
            "transition_saturation_front={:.18f}".format(transition_saturation_front),
            "transition_saturation_back={:.18f}".format(transition_saturation_back),
            "transition_saturation_back_start={:.18f}".format(transition_saturation_back_start),
            "chem_p={:.18f}".format(chem_p),
            "chem_scale={:.18f}".format(chem_scale),
            "reactivity_upbound={:.18f}".format(reactivity_upbound),
            "reactivity_lowbound={:.18f}".format(reactivity_lowbound),
            "htc={:.18f}".format(htc),
            "C_ratio={:.18f}".format(C_ratio),
            "overflow_Stransition_start={:.18f}".format(overflow_Stransition_start),
            "overflow_Stransition_end={:.18f}".format(overflow_Stransition_end),
            "overflow_Stransition_magnitude={:.18f}".format(overflow_Stransition_magnitude),
            "E={:.18f}".format(E),
            "nu={:.18f}".format(nu),
            "therm_expansion={:.18f}".format(g),
            "T0={:.18f}".format(T0),
            "gravity={:.18f}".format(gravity),
            "D_LP={:.18f}".format(D_LP),
            "l_c={:.18f}".format(l_c),
            "M_Si={:.18f}".format(M_Si),
            "M_SiC={:.18f}".format(M_SiC),
            "M_C={:.18f}".format(M_C),
            "rho_Si={:.18f}".format(rho_Si),
            "rho_SiC={:.18f}".format(rho_SiC),
            "rho_C={:.18f}".format(rho_C),
            "cp_Si={:.18f}".format(cp_Si),
            "cp_SiC={:.18f}".format(cp_SiC),
            "cp_C={:.18f}".format(cp_C),
            "k_C={:.18f}".format(k_C),
            "k_SiC={:.18f}".format(k_SiC),
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
        "dt={:.18f}".format(dt),
        "total_time={:.18f}".format(tcool + twait),
        "t_ramp={:.18f}".format(tcool),
        "dTdt={:.18f}".format(dTdt_cool),
        "D_macro={:.18f}".format(D_macro),
        "brooks_corey_threshold={:.18f}".format(brooks_corey_threshold),
        "capillary_pressure_power={:.18f}".format(capillary_pressure_power),
        "permeability_power={:.18f}".format(permeability_power),
        "mu_Si={:.18f}".format(mu_Si),
        "kappa_Si={:.18f}".format(kappa_Si),
        "kappa_Si_s={:.18f}".format(kappa_Si_s),
        "kappa_SiC={:.18f}".format(kappa_SiC),
        "kappa_C={:.18f}".format(kappa_C),
        "htc={:.18f}".format(htc),
        "E={:.18f}".format(E),
        "therm_expansion={:.18f}".format(g),
        "T0={:.18f}".format(Tmax),
        "Tref={:.18f}".format(Tref),
        "Ts={:.18f}".format(Ts),
        "Tf={:.18f}".format(Tf),
        "H_latent={:.18f}".format(H_latent),
        "M_Si={:.18f}".format(M_Si),
        "htc={:.18f}".format(htc),
        "phif_min={:.18f}".format(phif_min),
        "overflow_Stransition_start={:.18f}".format(overflow_Stransition_start),
        "overflow_Stransition_end={:.18f}".format(overflow_Stransition_end),
        "overflow_Stransition_magnitude={:.18f}".format(overflow_Stransition_magnitude),
        "therm_expansion={:.18f}".format(g),
        "solidification_rate={:.18f}".format(solidification_rate),
        "gravity={:.18f}".format(gravity),
        "rho_Si={:.18f}".format(rho_Si),
        "rho_Si_s={:.18f}".format(rho_Si_s),
        "rho_SiC={:.18f}".format(rho_SiC),
        "rho_C={:.18f}".format(rho_C),
        "cp_Si={:.18f}".format(cp_Si),
        "cp_Si_s={:.18f}".format(cp_Si_s),
        "cp_SiC={:.18f}".format(cp_SiC),
        "cp_C={:.18f}".format(cp_C),
        "kk_Si={:.18f}".format(perm_ref),
        "flux_out={:.18f}".format(flux_out),
        "meshfile={}".format(meshfile),
    ],
    stdin=subprocess.DEVNULL,
    stdout=open("solidification.log", "w"),
    stderr=subprocess.STDOUT,
    text=True,
)
proc2.wait()

end_time = time.perf_counter()

execution_time = end_time - start_time
print(f"Total time: {execution_time:.6f} seconds")