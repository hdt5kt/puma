############### Input ################
# Simulation parameters
dt = 10
total_time = 3600
t_ramp = ${total_time}
nx = 1000
xmax = 60

# Initial conditions
T0 = 1950 #K
Tmin = 500 #K

# Solidifciation Kinetics
Ts_low = 1687 #K
Ts_high = '${fparse Ts_low + 20}'
H_latent = 50555 #J mol-1

# Molar Mass # g mol-1
M_Si = 28.085

# denisty # g cm-3
rho_Si = 2.57 # density at liquid state

# specifc heat # Jg-1K-1
cp_Si = 0.7

# thermal conductivity # W/cm-1K-1
K = 7.5 # constant but could be a function of temperature

## Calculations
omega_Si = '${fparse M_Si/rho_Si}'
Tr0 = '${fparse (T0-Ts_low)/(Ts_high-Ts_low)}'
f0 = '${fparse if(Tr0<0,1,if(Tr0>1,0,1-(3*Tr0^2-2*Tr0^3)))}'
q0 = '${fparse if(f0<0,0,if(f0>1,H_latent,H_latent*(3*f0^2-2*f0^3)))}'

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
        diffusivity_derivative = dKdt
        variable = T
    []
    [time_dot]
        type = PumaTimeDerivative
        variable = T
        material_prop = rhocp
        material_prop_derivative = drhocpdT
    []
    [reaction_heat]
        type = MaterialSource #negative if source, positive if sink
        prop = qdot
        prop_derivative = neml2_dqdotdT
        coefficient = '${fparse -1/omega_Si}'
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

        moose_derivative_types = 'MATERIAL'
        moose_derivatives = 'neml2_dqdotdT'
        neml2_derivatives = 'state/qdot forces/T'

        initialize_outputs = '      f_Si_solid q'
        initialize_output_values = 'f0_Si_solid q0'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = ' f0_Si_solid q0'
        prop_values = '${f0}       ${q0}'
    []
    [const_mat_prop]
        type = GenericConstantMaterial
        prop_names = 'K rhocp dKdt drhocpdT'
        prop_values = '${K} ${fparse rho_Si*cp_Si} 0.0 0.0'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
[]

[AuxVariables]
    [f_Si_solid]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = f_Si_solid
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [qdot]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = qdot
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
        variable = 'T f_Si_solid qdot'
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
    #[right]
    #    type = FunctionDirichletBC
    #    boundary = right
    #    variable = T
    #    function = tramp
    #[]
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options_iname = '-pc_type -snes_type'
    petsc_options_value = 'lu vinewtonrsls'
    automatic_scaling = true

    nl_abs_tol = 1e-8

    end_time = ${total_time}
    dtmax = '${fparse dt}'

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
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
        file_base = 'checkqdot/out'
    []
    print_linear_residuals = false
[]