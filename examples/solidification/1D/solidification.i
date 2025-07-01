############### Input ################
# Simulation parameters
dt = 20
nx = 200

# models
Ts = 1687
Tf = 1717

# solidfication information
H_latent = 1.8e10 # erg/g
Tmax = 1800 #K
T0 = 1000 #K

# density
rho_Si = 2.57 # density at liquid state
rho_Si_s = 2.37 # density at solid state

# specific heat
cp_Si = 0.7e7 # erg/g-K
cp_Si_s = 0.5e7 # erg/g-K

# Heating conditions
dTdt = 10 #Kmin-1 heating rate
t_ramp = '${fparse (Tmax-T0)/dTdt*60}' #s
total_time = '${fparse t_ramp}'

# thermal conductivity
kappa_eff = 4e4 #[gcm/s3/K]

xmax = 2.0

[GlobalParams]
    temperature = 'T'
[]

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
    ## Temperature flow ---------------------------------------------------------
    [temp_time]
        type = PumaCoupledTimeDerivative
        material_prop = M1
        variable = T
        material_temperature_derivative = dM1dT
    []
    [temp_diffusion]
        type = PumaCoupledDiffusion
        material_prop = M2
        variable = T
        material_temperature_derivative = dM2dT
    []
    [reaction_heat]
        type = CoupledMaterialSource
        material_prop = M3
        variable = T
        material_temperature_derivative = dM3dT
    []
[]

[NEML2]
    input = 'neml2/neml2_material.i'
    cli_args = 'cp_rho_Si=${fparse cp_Si*rho_Si} cp_rho_Si_s=${fparse cp_Si_s*rho_Si_s}
                Ts=${Ts} Tf=${Tf} mL=${fparse rho_Si*H_latent}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE     VARIABLE      POSTPROCESSOR POSTPROCESSOR'
        moose_inputs = '     T            T             time          time'
        neml2_inputs = '     old_forces/T forces/T      forces/t      old_forces/t'

        moose_output_types = 'MATERIAL     MATERIAL   MATERIAL     MATERIAL     MATERIAL'
        moose_outputs = '     M1           M3         phif_l       phif_s       omcliquid'
        neml2_outputs = '     state/M1     state/M3   state/phif_l state/phif_s state/omcliquid'

        moose_derivative_types = 'MATERIAL           MATERIAL'
        moose_derivatives = '     dM3dT              dM1dT'
        neml2_derivatives = '     state/M3 forces/T; state/M1 forces/T'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'M2'
        prop_values = '${kappa_eff}'
    []
    [init_mat_derivative]
        type = GenericConstantMaterial
        prop_names = 'dM2dT'
        prop_values = '0.0'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
[]

[AuxVariables]
    [heat_release]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = M3
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [solidification_fraction]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = omcliquid
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phif_l]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phif_l
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phif_s]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phif_s
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
        variable = 'T heat_release solidification_fraction phif_l phif_s'
    []
[]

[ICs]
    [alphaIC]
        type = ConstantIC
        variable = T
        value = ${Tmax}
    []
[]

[Functions]
    [tramp]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '${Tmax} ${T0}'
    []
[]

[BCs]
    [left]
        type = FunctionDirichletBC
        boundary = left
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
    dtmax = '${fparse 10*dt}'

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