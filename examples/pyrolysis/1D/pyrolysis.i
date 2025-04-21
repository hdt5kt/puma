############### Input ################
# Simulation parameters
dt = 20
total_time = '${fparse 3600*1.75}'
nx = 200

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
Ea = 41220 # 177820 # J mol-1
A = 1.24e4 # 5.24e12 # s-1
R = 8.31446261815324 # JK-1mol-1
hrp = 1.58e6 # J kg-1

Y = 0.575
invYm1 = '${fparse 1-1/Y}' # 1-1/Y

order = 1.0
order_k = 0.00015
factor = 1.0

# models
cp_to_wg_relation = 0.001
op_to_solid_relation = 0.1
rho_g = 13 #kgm-3

# initial condition
ms0 = 1
mb0 = 10
mp0 = 3
mg0 = 0.001
mgcp0 = '${fparse mg0}'
phiop0 = 0.001 #void fraction
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

Tmax = 1000 #K
# Tref = 300 #K

dTdt = 10 #Kmin-1 heating rate
t_ramp = '${fparse (Tmax-T0)/dTdt*60}' #s

xmax = 1.0

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
        type = PumaDiffusion
        diffusivity = K
        diffusivity_derivative = neml2_dKdT
        variable = T
    []
    [time_dot]
        type = PumaTimeDerivative
        variable = T
        material_prop = rhocp
        material_prop_derivative = neml2_drhocpdT
    []
    [reaction_heat]
        type = MaterialSource
        prop = alphadot
        prop_derivative = neml2_dalphadotdT
        coefficient = '${fparse -factor*rho_s*hrp}'
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
                order=${order} order_k=${order_k} hrp=${hrp}
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
                              alphadot        K          V          rhocp'
        neml2_outputs = '     state/wb        state/wp   state/ws   state/wgcp   state/phiop
                              state/phib      state/phip state/phis state/phigcp state/alpha
                              state/alpha_dot state/K    state/V    state/rhocp'

        moose_derivative_types = 'MATERIAL                  MATERIAL              MATERIAL'
        moose_derivatives = '     neml2_dalphadotdT         neml2_drhocpdT        neml2_dKdT'
        neml2_derivatives = '     state/alpha_dot forces/T; state/rhocp forces/T; state/K forces/T'

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
[]

[AuxVariables]
    [wb]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = wb
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [wp]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = wp
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [ws]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = ws
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [wgcp]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = wgcp
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phib]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phib
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phip]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phip
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phis]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phis
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phigcp]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phigcp
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phiop]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phiop
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]

[VectorPostprocessors]
    [line]
        type = LineValueSampler
        end_point = '${xmax} 0 0'
        num_points = ${nx}
        sort_by = 'x'
        start_point = '0 0 0'
        variable = 'T wb wp ws wgcp phib phip phis phiop phigcp'
    []
[]

[ICs]
    [alphaIC]
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
    petsc_options_iname = '-pc_type -snes_type'
    petsc_options_value = 'lu vinewtonrsls'
    automatic_scaling = true

    nl_abs_tol = 1e-8

    end_time = ${total_time}
    dtmax = '${fparse 1*dt}'

    [TimeStepper]
        type = IterationAdaptiveDT
        dt = ${dt} #s
        optimal_iterations = 7
        iteration_window = 2
        cutback_factor = 0.5
        cutback_factor_at_failure = 0.1
        growth_factor = 1.2
        linear_iteration_ratio = 10000
    []
[]

[Outputs]
    exodus = true
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
        file_base = 'example_1D/out'
    []
    print_linear_residuals = false
[]