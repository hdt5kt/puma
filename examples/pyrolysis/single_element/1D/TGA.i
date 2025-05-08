############### Input ################
# Simulation parameters
dt = 0.1
nx = 1

# need to provide dTdt in terms of deg/minutes, Ea, and A from pyrolysis reaction types

# denisty kgm-3
rho_s = 2100
rho_b = 1250 # 1.2 and 1.4
rho_p = 3210

# heat capacity Jkg-1K-1
cp_s = 1592
cp_b = 1200
cp_g = 1e-4
cp_p = 750

# thermal conductivity W/m-1K-1
k_s = 1.5
k_b = 0.279
k_g = 1e-4
k_p = 380 #120 and 490

# reaction type
R = 8.31446261815324 # JK-1mol-1

Y = 0.56
invYm1 = '${fparse 1-1/Y}' # 1-1/Y

order = 7.0
order_k = 1.0

# models
cp_to_wg_relation = 0.001
op_to_solid_relation = 0.1
rho_g = 13 #kgm-3

# initial condition
ms0 = 0.001
mb0 = 10
mp0 = 0.001
mg0 = 0.0
mgcp0 = '${fparse mg0}'
phiop0 = 0.0 #void fraction
T0 = 300 #K

# calculations

Mref = '${fparse ms0 + mb0 + mp0 + mg0}'
V0 = '${fparse (ms0/rho_s + mb0/rho_b + mp0/rho_p + mgcp0/rho_g)/(1 - phiop0)}'
wb0 = '${fparse mb0/Mref}'
ws0 = '${fparse ms0/Mref}'
wp0 = '${fparse mp0/Mref}'
wgcp0 = '${fparse mgcp0/Mref}'
phis0 = '${fparse ws0*Mref/(rho_s*V0)}'
alpha0 = '${fparse 1/(1-Y)}' # 1/(1-Y)

xmax = '${fparse V0/nx}'

Tmax = 1500
total_time = '${fparse floor((Tmax -T0) / (dTdt/60))}' #s
t_ramp = ${total_time}

[Mesh]
    type = GeneratedMesh
    dim = 1
    nx = '${nx}'
    xmax = '${xmax}'
[]

[Variables]
    [T]
    []
[]

[Kernels]
    [heat_eq]
        type = Diffusion
        variable = T
    []
[]

[NEML2]
    input = 'neml2/PR_pyrolysis.i'
    cli_args = 'rho_s=${rho_s} rho_b=${rho_b} rho_g=${rho_g} rho_p=${rho_p} Mref=${Mref}
                rho_sm1M=${fparse Mref/rho_s} rho_bm1M=${fparse Mref/rho_b}
                rho_gm1M=${fparse Mref/rho_g} rho_pm1M=${fparse Mref/rho_p}
                cp_s=${cp_s} cp_b=${cp_b} cp_g=${cp_g} cp_p=${cp_p}
                k_s=${k_s} k_b=${k_b} k_g=${k_g} k_p=${k_p}
                Ea=${Ea} A=${A} R=${R} Y=${Y} invYm1=${invYm1}
                order=${order} order_k=${order_k}
                cp_to_wg_relation=${cp_to_wg_relation} op_to_solid_relation=${op_to_solid_relation}
                ws0=${ws0} wb0=${wb0} alpha0=${alpha0}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE     POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL'
        moose_inputs = '     T            time          time          alpha           phis
                             wb           wp            ws            wgcp            phiop
                             wb           wp            ws            wgcp            phiop'
        neml2_inputs = '     forces/T     forces/tt     old_forces/tt old_state/alpha old_state/phis
                             state/wb     state/wp      state/ws      state/wgcp      state/phiop
                             old_state/wb old_state/wp  old_state/ws  old_state/wgcp  old_state/phiop'

        moose_output_types = 'MATERIAL        MATERIAL   MATERIAL   MATERIAL     MATERIAL
                              MATERIAL        MATERIAL   MATERIAL   MATERIAL     MATERIAL
                              MATERIAL        MATERIAL   MATERIAL   MATERIAL'
        moose_outputs = '     wb              wp         ws         wgcp         phiop
                              phib            phip       phis       phigcp       alpha
                              alpha_dot       K          V          rhocp'
        neml2_outputs = '     state/wb        state/wp   state/ws   state/wgcp   state/phiop
                              state/phib      state/phip state/phis state/phigcp state/alpha
                              state/alpha_dot state/K    state/V     state/rhocp'

        #moose_derivative_types = ''
        #moose_derivatives = ''
        #neml2_derivatives = ''

        initialize_outputs = '      wp  wb  wgcp  ws  alpha  phis  phiop'
        initialize_output_values = 'wp0 wb0 wgcp0 ws0 alpha0 phis0 phiop0'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'wp0 wb0 wgcp0 ws0 alpha0 phis0 phiop0'
        prop_values = '${wp0} ${wb0} ${wgcp0} ${ws0} ${alpha0} ${phis0} ${phiop0}'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
    [temp]
        type = ElementAverageValue
        variable = T
    []
    [alphadot]
        type = ElementAverageMaterialProperty
        mat_prop = alpha_dot
    []
    [ws]
        type = ElementAverageMaterialProperty
        mat_prop = ws
    []
    [wb]
        type = ElementAverageMaterialProperty
        mat_prop = wb
    []
    [wp]
        type = ElementAverageMaterialProperty
        mat_prop = wp
    []
    [wgcp]
        type = ElementAverageMaterialProperty
        mat_prop = wgcp
    []
    ########## VOLUME FRACTION #################################
    [phis]
        type = ElementAverageMaterialProperty
        mat_prop = phis
    []
    [phib]
        type = ElementAverageMaterialProperty
        mat_prop = phib
    []
    [phip]
        type = ElementAverageMaterialProperty
        mat_prop = phip
    []
    [phigcp]
        type = ElementAverageMaterialProperty
        mat_prop = phigcp
    []
    [phiop]
        type = ElementAverageMaterialProperty
        mat_prop = phiop
    []
    ########## ELEMENT FRACTION #################################
    [K]
        type = ElementAverageMaterialProperty
        mat_prop = K
    []
    [V]
        type = ElementAverageMaterialProperty
        mat_prop = V
    []
    [rhocp]
        type = ElementAverageMaterialProperty
        mat_prop = rhocp
    []
[]

[ICs]
    [TIC]
        type = ConstantIC
        variable = T
        value = ${T0}
    []
[]

[Functions]
    [tramp]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '${T0} ${Tmax}'
    []
[]

[BCs]
    [left]
        type = FunctionDirichletBC
        boundary = left
        variable = T
        function = tramp
    []
    [right]
        type = FunctionDirichletBC
        boundary = right
        variable = T
        function = tramp
    []
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options_iname = '-pc_type' # -snes_type'
    petsc_options_value = 'lu' # vinewtonrsls'
    automatic_scaling = true

    nl_abs_tol = 1e-8

    end_time = ${total_time}
    dtmax = '${fparse 100*dt}'

    [TimeStepper]
        type = IterationAdaptiveDT
        dt = ${dt} #s
        optimal_iterations = 6
        iteration_window = 2
        cutback_factor = 0.5
        cutback_factor_at_failure = 0.1
        growth_factor = 1.2
        linear_iteration_ratio = 10000
    []
[]

[Outputs]
    exodus = true
    console = false
    [csv]
        type = CSV
        file_base = 'simulation/out_${num}'
    []
    print_linear_residuals = false
[]