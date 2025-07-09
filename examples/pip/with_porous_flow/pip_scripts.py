import numpy as np
import subprocess
from generate_random_field import generate_initial_conditions

########################################## Input ##############################################
##                                                                                           ##
## Currently assumed the resin fully filled the open pores gas during polymer infiltration   ##
## all of the gas managed to escaped, pores production based on the amount of initial binder ##
## trapped gas production based on the porosity at the begining of the pyrolysis             ##
##                                                                                           ##
###############################################################################################

pip_cycle_n = 10  # number of pip cycles
save_folder = "main"
corenum = 8  # number of cores used for simulation
puma_run_file = "./../../../puma-opt"


# rate of close pore relative to volume of produced gas
def cp_to_wg_relation(volume_binder, relation=0.001):
    return relation


# portion of open pores as a function of binder consumed
def op_to_binder_relation(v_nonreactants, relation=0.8):
    return relation


# gas density as a function of temperature and pressure
def rho_g(T, P):
    return 13  # kg m-3


########################### parts and geometry information ####################################
# geometry
mesh_file = "gold/2D_plane.msh"
reference_mass = 1.0  # reference mass
xroll = 0.1
yroll = 0.0
zroll = 0.0
xfix = 0.0
yfix = 0.0
zfix = 0.0

# initial conditions, assumed a binary system (binder and particle) at the begining
mode = "mass_fraction"
min_binder = 0.3
max_binder = 0.7
lc = 0.005

############################# material and reaction properties ################################
##           Current properties are for phenolic resin inside SiC praticles                  ##

# universal constant
R = 8.31446261815324  # JK-1mol-1

# denisty kgm-3
rho_s = 2260
rho_b = 1250  # 1.2 and 1.4
rho_p = 3210

# heat capacity Jkg-1K-1
cp_s = 1592
cp_b = 1200
cp_p = 750
cp_g = 1e-4

# thermal conductivity W/m-1K-1
k_s = 150
k_b = 279
k_p = 380  # 120 and 490
k_g = 1e-4

# reaction type for pyrolysis
Ea = 208170  # J mol-1
A = 0.7e14  # s-1
hrp = 1.58e5  # e6 J kg-1
Y = 0.55  # char yield [.]
order = 7.4496

# reaction type for curing
Ea_cur = 98000  # J mol-1
A_cur = 1e12  # s-1
hrp_cur = 1.58e5  # e6 J kg-1
Y_cur = 0.9  # char yield [.]
order_cur = 1.0

#### stress-strain ####
E = 400e9

# thermal expansion coefficients (degree-1)
Tref = 300  # K
g = 0.0  # 4e-6

# convection coefficients - Wm-2K
htc = 200

# heating profiles for pyrolysis
T0 = 300  # K - starting and cooling temperatures
Tmax = 1400  # K
dTdt = 20  # Kmin-1 heating rate
t_hold = 0.5  # hrs
tcool = 0.5  # hrs

# heating profiles for curing
T0_cur = 300  # K - starting and cooling temperatures
Tmax_cur = 420  # K
dTdt_cur = 20  # Kmin-1 heating rate
t_hold_cur = 0.5  # hrs
tcool_cur = 0.5  # hrs

# Simulation parameters
dt = 5

###############################################################################################
##                                                                                           ##
##                                       MAIN                                                ##
##                                                                                           ##
###############################################################################################

# remove the save folder if it exists
subprocess.run(["rm", "-rf", save_folder])

# generate the initial conditions
intial_condition = generate_initial_conditions(
    mesh_file,
    lc,
    mode=mode,
    Mref=reference_mass,
    rho_b=rho_b,
    rho_p=rho_p,
    min_binder=min_binder,
    max_binder=max_binder,
    beta_a_binder=2.0,
    beta_b_binder=5.0,
    seed_binder=4562,
    plot_cond=True,
)

num_file_data = len(intial_condition["z"])


print("\n")

print("Starting PIP cycle #" + str(1) + ":")

print("Pyrolysis\n")

# run the simulation file PR_pyrolysis.i and initical_condition_from_csv.i
subprocess.run(
    [
        "mpiexec",
        "-n",
        str(corenum),
        puma_run_file,
        "-i",
        "pyrolysis.i",
        "initial_condition_from_csv.i",
        "rho_s={:.9f}".format(rho_s),
        "rho_b={:.9f}".format(rho_b),
        "rho_g={:.9f}".format(rho_g(1, 1)),
        "rho_p={:.9f}".format(rho_p),
        "cp_s={:.9f}".format(cp_s),
        "cp_b={:.9f}".format(cp_b),
        "cp_p={:.9f}".format(cp_p),
        "cp_g={:.9f}".format(cp_p),
        "k_s={:.9f}".format(k_s),
        "k_b={:.9f}".format(k_b),
        "k_p={:.9f}".format(k_p),
        "k_g={:.9f}".format(k_p),
        "Ea={:.9f}".format(Ea),
        "A={:.9f}".format(A),
        "R={:.9f}".format(R),
        "hrp={:.9f}".format(hrp),
        "Y={:.9f}".format(Y),
        "order={:.9f}".format(order),
        "E={:.9f}".format(E),
        "g={:.9f}".format(g),
        "Tref={:.9f}".format(Tref),
        "htc={:.9f}".format(htc),
        "dTdt={:.9f}".format(dTdt),
        "Tmax={:.9f}".format(Tmax),
        "t_hold={:.9f}".format(t_hold),
        "tcool={:.9f}".format(tcool),
        "T0={:.9f}".format(T0),
        "dTdt={:.9f}".format(dTdt),
        "pyro_mu={:.9f}".format(cp_to_wg_relation(1)),
        "zeta={:.9f}".format(op_to_binder_relation(1)),
        "meshfile={}".format(mesh_file),
        "xroll={:.9f}".format(xroll),
        "yroll={:.9f}".format(yroll),
        "zroll={:.9f}".format(zroll),
        "xfix={:.9f}".format(xfix),
        "yfix={:.9f}".format(yfix),
        "zfix={:.9f}".format(zfix),
        "Mref={:.9f}".format(reference_mass),
        "num_file_data={}".format(num_file_data),
        "save_folder={}".format(save_folder),
        "save_cycle={}".format(str(1)),
        "save_type={}".format("pyrolysis"),
        # "--parse-neml2-only",
    ]
)

for i in range(pip_cycle_n - 1):

    print("\nInfiltration\n")

    print("\nCuring\n")
    # run the simulation file PR_pyrolysis.i and initial_condition_from_exodus_1.i
    subprocess.run(
        [
            "mpiexec",
            "-n",
            str(corenum),
            puma_run_file,
            "-i",
            "curing.i",
            "initial_condition_from_exodus_1.i",
            "rho_s={:.9f}".format(rho_s),
            "rho_b={:.9f}".format(rho_b),
            "rho_g={:.9f}".format(rho_g(1, 1)),
            "rho_p={:.9f}".format(rho_p),
            "cp_s={:.9f}".format(cp_s),
            "cp_b={:.9f}".format(cp_b),
            "cp_p={:.9f}".format(cp_p),
            "cp_g={:.9f}".format(cp_p),
            "k_s={:.9f}".format(k_s),
            "k_b={:.9f}".format(k_b),
            "k_p={:.9f}".format(k_p),
            "k_g={:.9f}".format(k_p),
            "Ea={:.9f}".format(Ea_cur),
            "A={:.9f}".format(A_cur),
            "R={:.9f}".format(R),
            "hrp={:.9f}".format(hrp_cur),
            "Y={:.9f}".format(Y_cur),
            "order={:.9f}".format(order_cur),
            "E={:.9f}".format(E),
            "g={:.9f}".format(g),
            "Tref={:.9f}".format(Tref),
            "htc={:.9f}".format(htc),
            "dTdt={:.9f}".format(dTdt_cur),
            "Tmax={:.9f}".format(Tmax_cur),
            "t_hold={:.9f}".format(t_hold_cur),
            "tcool={:.9f}".format(tcool_cur),
            "T0={:.9f}".format(T0_cur),
            "dTdt={:.9f}".format(dTdt_cur),
            "pyro_mu={:.9f}".format(cp_to_wg_relation(1, 0.0)),
            "zeta={:.9f}".format(op_to_binder_relation(1, 0.1)),
            "meshfile={}".format(mesh_file),
            "xroll={:.9f}".format(xroll),
            "yroll={:.9f}".format(yroll),
            "zroll={:.9f}".format(zroll),
            "xfix={:.9f}".format(xfix),
            "yfix={:.9f}".format(yfix),
            "zfix={:.9f}".format(zfix),
            "Mref={:.9f}".format(reference_mass),
            "save_folder={}".format(save_folder),
            "save_cycle={}".format(str(i + 1)),
            "load_cycle={}".format(str(i + 1)),
            "save_type={}".format("curing"),
            "load_type={}".format("pyrolysis"),
        ]
    )

    print("Starting PIP cycle #" + str(i + 2) + ":")
    print("\nPyrolysis\n")

    # run the simulation file PR_pyrolysis.i and initial_condition_from_exodus.i
    subprocess.run(
        [
            "mpiexec",
            "-n",
            str(corenum),
            puma_run_file,
            "-i",
            "pyrolysis.i",
            "initial_condition_from_exodus_2.i",
            "rho_s={:.9f}".format(rho_s),
            "rho_b={:.9f}".format(rho_b),
            "rho_g={:.9f}".format(rho_g(1, 1)),
            "rho_p={:.9f}".format(rho_p),
            "cp_s={:.9f}".format(cp_s),
            "cp_b={:.9f}".format(cp_b),
            "cp_p={:.9f}".format(cp_p),
            "cp_g={:.9f}".format(cp_p),
            "k_s={:.9f}".format(k_s),
            "k_b={:.9f}".format(k_b),
            "k_p={:.9f}".format(k_p),
            "k_g={:.9f}".format(k_p),
            "Ea={:.9f}".format(Ea),
            "A={:.9f}".format(A),
            "R={:.9f}".format(R),
            "hrp={:.9f}".format(hrp),
            "Y={:.9f}".format(Y),
            "order={:.9f}".format(order),
            "E={:.9f}".format(E),
            "g={:.9f}".format(g),
            "Tref={:.9f}".format(Tref),
            "htc={:.9f}".format(htc),
            "dTdt={:.9f}".format(dTdt),
            "Tmax={:.9f}".format(Tmax),
            "t_hold={:.9f}".format(t_hold),
            "tcool={:.9f}".format(tcool),
            "T0={:.9f}".format(T0),
            "dTdt={:.9f}".format(dTdt),
            "pyro_mu={:.9f}".format(cp_to_wg_relation(1)),
            "zeta={:.9f}".format(op_to_binder_relation(1)),
            "meshfile={}".format(mesh_file),
            "xroll={:.9f}".format(xroll),
            "yroll={:.9f}".format(yroll),
            "zroll={:.9f}".format(zroll),
            "xfix={:.9f}".format(xfix),
            "yfix={:.9f}".format(yfix),
            "zfix={:.9f}".format(zfix),
            "Mref={:.9f}".format(reference_mass),
            "save_folder={}".format(save_folder),
            "load_cycle={}".format(str(i + 1)),
            "save_cycle={}".format(str(i + 2)),
            "save_type={}".format("pyrolysis"),
            "load_type={}".format("curing"),
        ]
    )
