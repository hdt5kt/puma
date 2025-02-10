############### Input ################
# Simulation parameters
dt = 0.1
total_time = 3600
t_ramp = ${total_time}
nx = 1

# denisty kgm-3
rho_s = 320
rho_b = 1250 # 1.2 and 1.4
rho_g = 1
rho_p = 3210

rho_sm1 = '${fparse 1/rho_s}'
rho_bm1 = '${fparse 1/rho_b}'
rho_gm1 = '${fparse 1/rho_g}'
rho_pm1 = '${fparse 1/rho_p}'

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
Ea = 177820 # J mol-1
A = 5.24e12 # s-1
R = 8.31446261815324 # JK-1mol-1
#hrp = 1.58e6 # J kg-1

Y = 0.7
Ym1 = '${fparse 1/Y}' # 1/Y
invYm1 = '${fparse 1-1/Y}' # 1-1/Y

order = 1.0
order_k = 1.0

# initial condition
ms0 = 1.0
mb0 = 10
mp0 = 13
mg0 = 0.0
alpha0 = '${fparse 1/(1-Y)}' # 1/(1-Y)
vv0 = 0.1 #void fraction
Vv0 = '${fparse vv0/(1-vv0)*(ms0/rho_s + mb0/rho_b + mp0/rho_p)}'

V0 = '${fparse ms0/rho_s + mb0/rho_b + mp0/rho_p + Vv0}'

xmax = '${fparse V0/nx}'

T0 = 400 #K
Tmax = 800 #K
#Tref = 273 #K

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
    cli_args = 'rho_s=${rho_s} rho_b=${rho_b} rho_g=${rho_g} rho_p=${rho_p}
                rho_sm1=${rho_sm1} rho_bm1=${rho_bm1} rho_gm1=${rho_gm1} rho_pm1=${rho_pm1}
                cp_s=${cp_s} cp_b=${cp_b} cp_g=${cp_g} cp_p=${cp_p}
                k_s=${k_s} k_b=${k_b} k_g=${k_g} k_p=${k_p}
                Ea=${Ea} A=${A} R=${R} Y=${Y} Ym1=${Ym1} invYm1=${invYm1}
                order=${order} order_k=${order_k}
                ms0=${ms0} mb0=${mb0} mg0=${mg0} mp0=${mp0} Vv0=${Vv0} alpha0=${alpha0}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL MATERIAL MATERIAL MATERIAL MATERIAL MATERIAL     MATERIAL     MATERIAL     MATERIAL     MATERIAL'
        moose_inputs = '     T        time          time          alpha           mb       mg       mp       ms       Vv       mb           mg           mp           ms           Vv'
        neml2_inputs = '     forces/T forces/tt     old_forces/tt old_state/alpha state/mb state/mg state/mp state/ms state/Vv old_state/mb old_state/mg old_state/mp old_state/ms old_state/Vv'

        moose_output_types = 'MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL'
        moose_outputs = '     mp       mb       mg        ms
                              wp       wb       ws        alpha
                              vp       vb       vv        vs
                              Vp       Vb       Vv        Vs
                              K        V        rho       cp'
        neml2_outputs = '     state/mp state/mb state/mg  state/ms
                              state/wp state/wb state/ws  state/alpha
                              state/vp state/vb state/vv  state/vs
                              state/Vp state/Vb state/Vv  state/Vs
                              state/K  state/V  state/rho state/cp'

        #moose_derivative_types = ''
        #moose_derivatives = ''
        #neml2_derivatives = ''

        initialize_outputs = '      mp  mb  mg  ms  alpha  Vv'
        initialize_output_values = 'mp0 mb0 mg0 ms0 alpha0 Vv0'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'mp0 mb0 mg0 ms0 alpha0 Vv0'
        prop_values = '${mp0} ${mb0} ${mg0} ${ms0} ${alpha0} ${Vv0}'
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
    [ms]
        type = ElementAverageMaterialProperty
        mat_prop = ms
    []
    [mb]
        type = ElementAverageMaterialProperty
        mat_prop = mb
    []
    [mg]
        type = ElementAverageMaterialProperty
        mat_prop = mg
    []
    [mp]
        type = ElementAverageMaterialProperty
        mat_prop = mp
    []
    [alpha]
        type = ElementAverageMaterialProperty
        mat_prop = alpha
    []
    ########## WEIGHT FRACTION #################################
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
    ########## VOLUME #################################
    [Vs]
        type = ElementAverageMaterialProperty
        mat_prop = Vs
    []
    [Vb]
        type = ElementAverageMaterialProperty
        mat_prop = Vb
    []
    [Vp]
        type = ElementAverageMaterialProperty
        mat_prop = Vp
    []
    [Vv]
        type = ElementAverageMaterialProperty
        mat_prop = Vv
    []
    ########## VOLUME FRACTION #################################
    [vs]
        type = ElementAverageMaterialProperty
        mat_prop = vs
    []
    [vb]
        type = ElementAverageMaterialProperty
        mat_prop = vb
    []
    [vp]
        type = ElementAverageMaterialProperty
        mat_prop = vp
    []
    [vv]
        type = ElementAverageMaterialProperty
        mat_prop = vv
    []
    ########## ELEMENT FRACTION #################################
    [K]
        type = ElementAverageMaterialProperty
        mat_prop = K
    []
    [cp]
        type = ElementAverageMaterialProperty
        mat_prop = cp
    []
    [V]
        type = ElementAverageMaterialProperty
        mat_prop = V
    []
    [rho]
        type = ElementAverageMaterialProperty
        mat_prop = rho
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
        file_base = 'solution1/out'
    []
    print_linear_residuals = false
[]