############### Input ################
# Simulation parameters
dt = 5
total_time = '${fparse 3600*3.0}'
nx = 200

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
hrp = 1.58e6 #e6 J kg-1
factor = 1.0

Y = 0.7
Ym1 = '${fparse 1/Y}' # 1/Y
invYm1 = '${fparse 1-1/Y}' # 1-1/Y

order = 1.0
order_k = 1.0

# initial condition #kg
ms0 = 300
mb0 = 1200
mp0 = 3000
mg0 = 1e-4
alpha0 = '${fparse 1/(1-Y)}' # 1/(1-Y)
vv0 = 0.1 #void fraction
Vv0 = '${fparse vv0/(1-vv0)*(ms0/rho_s + mb0/rho_b + mp0/rho_p)}'

V0 = '${fparse ms0/rho_s + mb0/rho_b + mp0/rho_p + Vv0}'

xmax = '${fparse V0^(1/3)}'
#xmax = '${fparse nx*dx}'

T0 = 300 #K
Tmax = 1200 #K
#Tref = 300 #K

dTdt = 10 #Kmin-1 heating rate
t_ramp = '${fparse (Tmax-T0)/dTdt*60}' #s

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

        moose_input_types = 'VARIABLE     POSTPROCESSOR POSTPROCESSOR MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL'
        moose_inputs = '     T            time          time          alpha
                             mb           mg            mp            ms              Vv
                             mb           mg            mp            ms              Vv'
        neml2_inputs = '     forces/T     forces/tt     old_forces/tt old_state/alpha
                             state/mb     state/mg      state/mp      state/ms        state/Vv
                             old_state/mb old_state/mg  old_state/mp  old_state/ms    old_state/Vv'

        moose_output_types = 'MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL    MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL
                              MATERIAL MATERIAL MATERIAL  MATERIAL    MATERIAL'
        moose_outputs = '     mp       mb       mg        ms
                              wp       wb       ws        alpha       alphadot
                              vp       vb       vv        vs
                              Vp       Vb       Vv        Vs
                              K        V        rho       cp          rhocp'
        neml2_outputs = '     state/mp state/mb state/mg  state/ms
                              state/wp state/wb state/ws  state/alpha state/alpha_dot
                              state/vp state/vb state/vv  state/vs
                              state/Vp state/Vb state/Vv  state/Vs
                              state/K  state/V  state/rho state/cp    state/rhocp'

        moose_derivative_types = 'MATERIAL                  MATERIAL              MATERIAL'
        moose_derivatives = '     neml2_dalphadotdT         neml2_drhocpdT        neml2_dKdT'
        neml2_derivatives = '     state/alpha_dot forces/T; state/rhocp forces/T; state/K forces/T'

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
    [vb]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = vb
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [vp]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = vp
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [vs]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = vs
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [vv]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = vv
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
        variable = 'T wb wp ws vb vp vs vv'
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
        file_base = 'diff_time_heat_v3/out'
    []
    print_linear_residuals = false
[]