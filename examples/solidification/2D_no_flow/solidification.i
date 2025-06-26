############### Input ################
# Simulation parameters
dt = 20
nx = 40

# models
Ts = 1687
Tf = 1717

# Molar Mass # g mol-1
M_Si = 28.085

# solidfication information
H_latent = 1.8e7 # erg/g
Tmax = 1800 #K
T0 = 300 #K

# fluid information
swelling_coef = 0.02

# density
rho_Si = 2.57 # density at liquid state
rho_Si_s = 2.37 # density at solid state

# specific heat
cp_Si = 0.7e7 # erg/g-K
cp_Si_s = 0.5e7 # erg/g-K

# Heating conditions
dTdt = -10 #Kmin-1 heating rate
t_ramp = '${fparse (T0-Tmax)/dTdt*60}' #s
total_time = '${fparse t_ramp}'

# thermal conductivity
kappa_eff = 4e4 #[gcm/s3/K]

# solid mechnanics
E = 1000
nu = 0.3
g = 1e-4
Tref = 300

#boundary conditions
htc = 20000 #g / s3-K

xmax = 2.0

# Calculations
omega_Si_s = '${fparse M_Si/rho_Si_s}'
omega_Si_l = '${fparse M_Si/rho_Si}'
dOmega_f = '${fparse (omega_Si_s-omega_Si_l)/omega_Si_l}'

[GlobalParams]
    temperature = 'T'
    displacements = 'disp_x disp_y'
    stabilize_strain = true
[]

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = '${nx}'
    ny = '${nx}'
    xmax = '${xmax}'
    ymax = '${xmax}'
[]

[Variables]
    [T]
    []
[]

[Physics]
    [SolidMechanics]
        [QuasiStatic]
            [sample]
                new_system = true
                add_variables = true
                strain = FINITE
                formulation = TOTAL
                volumetric_locking_correction = true
                generate_output = "pk1_stress_xx pk1_stress_yy pk1_stress_zz 
                                    pk1_stress_xy pk1_stress_xz pk1_stress_yz
                                    max_principal_pk1_stress vonmises_pk1_stress"
            []
        []
    []
[]

[Kernels]
    ## Temperature flow ---------------------------------------------------------
    [temp_time]
        type = PumaCoupledTimeDerivative
        material_prop = M1
        variable = T
        material_temperature_derivative = dM1dT
        material_deformation_gradient_derivative = dM1dF
    []
    [temp_diffusion]
        type = PumaCoupledDiffusion
        material_prop = M2
        variable = T
        material_temperature_derivative = dM2dT
        material_deformation_gradient_derivative = zeroR2
    []
    [reaction_heat]
        type = CoupledMaterialSource
        material_prop = M3
        variable = T
        material_temperature_derivative = dM3dT
        material_deformation_gradient_derivative = dM3dF
    []
    ## solid mechanics ---------------------------------------------------------
    [offDiagStressDiv_x]
        type = MomentumBalanceCoupledJacobian
        component = 0
        variable = disp_x
        material_temperature_derivative = dpk1dT
    []
    [offDiagStressDiv_y]
        type = MomentumBalanceCoupledJacobian
        component = 1
        variable = disp_y
        material_temperature_derivative = dpk1dT
    []
[]

[NEML2]
    input = 'neml2/neml2_material.i'
    cli_args = 'cp_rho_Si=${fparse cp_Si*rho_Si} cp_rho_Si_s=${fparse cp_Si_s*rho_Si_s}
                Ts=${Ts} Tf=${Tf} mL=${fparse rho_Si*H_latent}
                swelling_coef=${swelling_coef} dOmega_f=${dOmega_f} Tref=${Tref}
                kappa_eff=${kappa_eff} E=${E} nu=${nu} therm_expansion=${g}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE     VARIABLE      POSTPROCESSOR POSTPROCESSOR MATERIAL     '
        moose_inputs = '     T            T             time          time          deformation_gradient'
        neml2_inputs = '     old_forces/T forces/T      forces/t      old_forces/t  forces/F'

        moose_output_types = 'MATERIAL     MATERIAL   MATERIAL     MATERIAL     MATERIAL
                              MATERIAL'
        moose_outputs = '     M1           M3         phif_l       phif_s       omcliquid
                              pk1_stress'
        neml2_outputs = '     state/M1     state/M3   state/phif_l state/phif_s state/omcliquid
                              state/pk1'

        moose_derivative_types = 'MATERIAL           MATERIAL           MATERIAL
                                  MATERIAL           MATERIAL           MATERIAL'
        moose_derivatives = '     dM3dT              dM1dT              dpk1dT
                                  dM3dF              dM1dF              pk1_jacobian'
        neml2_derivatives = '     state/M3 forces/T; state/M1 forces/T; state/pk1 forces/T;
                                  state/M3 forces/F; state/M1 forces/F; state/pk1 forces/F'
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
    [zeroR2]
        type = GenericConstantRankTwoTensor
        tensor_name = 'zeroR2'
        tensor_values = '0 0 0 0 0 0 0 0 0'
    []
    [convection]
        type = ADParsedMaterial
        property_name = q_boundary
        expression = 'htc*(T - if(time<t_ramp, Tmax + dTdt/60*time, Tmax + dTdt/60*t_ramp))'
        coupled_variables = T
        constant_names = 'htc t_ramp dTdt  Tmax'
        constant_expressions = '${htc} ${t_ramp} ${dTdt} ${Tmax}'
        postprocessor_names = 'time'
        boundary = 'top right'
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

[ICs]
    [T_IC]
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
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = 'top right'
        variable = T
        value = -1
    []
    [roll_y]
        type = DirichletBC
        boundary = 'bottom'
        value = 0.0
        variable = disp_y
    []
    [roll_x]
        type = DirichletBC
        boundary = 'left'
        value = 0.0
        variable = disp_x
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
    []
    print_linear_residuals = false
[]