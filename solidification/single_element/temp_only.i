############### Input ################
# Simulation parameters
dt = 0.1
total_time = 3600
t_ramp = ${total_time}
nx = 1
xmax = 1

# Initial conditions
T0 = 1800 #K
Tmin = 500 #K

# Solidifciation Kinetics
Ts_low = 1687 #K
Ts_high = '${fparse Ts_low + 8}'
H_latent = 50555 #J mol-1

# Molar Mass # g mol-1
#M_Si = 28.085

# denisty # g cm-3
#rho_Si = 2.57 # density at liquid state

## Calculations
#omega_Si = '${fparse M_Si/rho_Si}'

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
    input = 'neml2/Si_solidify.i'
    cli_args = 'Ts_low=${Ts_low} Ts_high=${Ts_high} H_latent=${H_latent}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE      POSTPROCESSOR POSTPROCESSOR MATERIAL'
        moose_inputs = '     T             time          time          q'
        neml2_inputs = '     forces/T      forces/t      old_forces/t  old_state/q'

        moose_output_types = 'MATERIAL      MATERIAL   MATERIAL'
        moose_outputs = '     f_Si_solid    qdot       q'
        neml2_outputs = '     state/f_solid state/qdot state/q'

        #moose_derivative_types = ''
        #moose_derivatives = ''
        #neml2_derivatives = ''

        initialize_outputs = '      f_Si_solid  qdot  q'
        initialize_output_values = 'f0_Si_solid q0dot q0'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'f0_Si_solid q0dot q0'
        prop_values = '0.0 0.0 0.0'
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
    [f_Si_solid]
        type = ElementAverageMaterialProperty
        mat_prop = f_Si_solid
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
        y = '${T0} ${Tmin}'
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