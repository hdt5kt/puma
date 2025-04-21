############### Input ################
# density # kg per m3
rho_Si = 2330
rho_C = 2210

# heat capacity Jkg-1K-1
cp_Si = 705
cp_C = 710

# thermal conductivity W/m-1K-1
k_Si = 140
k_C = 130

# Simulation parameters
dt = 30 #s

T0 = 300 #K
Tmax = 1773 #K

dTdt = 300 #Kmin-1 heating rate
t_ramp = '${fparse (Tmax-T0)/dTdt*60}' #s
t_hold = 0.5 #hrs
theat = '${fparse t_ramp+t_hold*3600}'

total_time = '${fparse theat}'

#boundary conditions
htc = 25 #Wm-2K assume air doesnt move much

[Mesh]
    [mesh0]
        type = FileMeshGenerator
        file = 'gold/core_in_meltpool.msh'
    []
    [scale]
        type = TransformGenerator
        input = mesh0
        transform = SCALE
        vector_value = '0.01 0.01 0.01'
    []
    coord_type = 'rz'
[]

[Variables]
    [T]
        initial_condition = ${T0}
    []
[]

[Kernels]
    [heat_eq]
        type = PumaDiffusion
        diffusivity = K
        diffusivity_derivative = 0
        variable = T
    []
    [time_dot]
        type = PumaTimeDerivative
        variable = T
        material_prop = rhocp
        material_prop_derivative = 0
    []
[]

[Materials]
    [graphite]
        type = GenericConstantMaterial
        prop_names = 'rhocp K'
        prop_values = '${fparse rho_C*cp_C} ${fparse k_C}'
        block = 'cores'
    []
    [silicon]
        type = GenericConstantMaterial
        prop_names = 'rhocp K'
        prop_values = '${fparse rho_Si*cp_Si} ${fparse k_Si}'
        block = 'melt_pool'
    []
    [convection]
        type = ADParsedMaterial
        property_name = q_boundary
        expression = 'htc*(T - if(time<t_ramp,(dTdt/60)*t_ramp,Tmax))'
        coupled_variables = T
        constant_names = 'htc t_ramp dTdt theat Tmax'
        constant_expressions = '${htc} ${t_ramp} ${dTdt} ${theat} ${Tmax}'
        postprocessor_names = 'time'
        boundary = 'expose_boundary'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
[]

[BCs]
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = 'expose_boundary'
        variable = T
        value = -1
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
        file_base = 'low_fidelity_model/out'
    []
    print_linear_residuals = false
[]