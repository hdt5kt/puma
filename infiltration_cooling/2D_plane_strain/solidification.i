base_folder = 'different_initial_phiC'

############### Input ################
# Simulation parameters
dt = 1

# Initial conditions
T0 = 1800 #K
Tmin = 300 #K

# Solidifciation Kinetics
Ts_low = 1687 #K
Ts_high = '${fparse Ts_low + 20}'
H_latent = 50555 #J mol-1

# Molar Mass # g mol-1
M_Si = 28.085
# M_SiC = 40.11
# M_C = 12.011

# denisty # g cm-3
rho_Si = 2.57 # density at liquid state
rho_Si_s = 2.37 # density at solid state
# rho_SiC = 3.21
# rho_C = 2.26

# specifc heat # Jg-1K-1
cp_Si = 0.7

# thermal conductivity # W/cm-1K-1
K = 1.5 # constant but could be a function of temperature

# Calculations
omega_Si = '${fparse M_Si/rho_Si}'
omega_Si_s = '${fparse M_Si/rho_Si_s}'
omega_Si_l = '${fparse M_Si/rho_Si}'

Tr0 = '${fparse (T0-Ts_low)/(Ts_high-Ts_low)}'
f0 = '${fparse if(Tr0<0,1,if(Tr0>1,0,1-(3*Tr0^2-2*Tr0^3)))}'
q0 = '${fparse if(f0<0,0,if(f0>1,H_latent,H_latent*(3*f0^2-2*f0^3)))}'

deltaOmega = '${fparse (omega_Si_s-omega_Si_l)}'

# Boundary Conditions
tcool = 0.5 #hours
dTdtcool = '${fparse (T0-Tmin)/(tcool*3600)}' #Ks-1
twait = 3 #hours
total_time = '${fparse (twait+tcool)*3600}'

#### stress-strain ####
E = 150e9 #GPa
mu = 0.3

#boundary conditions
htc = 0.1 #Wcm-2K

[GlobalParams]
    displacements = 'disp_x disp_y'
[]

[Mesh]
    [mesh0]
        type = FileMeshGenerator
        file = '${base_folder}/core.e'
        # exodus_extra_element_integers = 'phi_Si'
    []
    #[shift]
    #    type = TransformGenerator
    #    input = mesh0
    #    transform = TRANSLATE_MIN_ORIGIN
    #[]
    [rollingnode]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '12.99999 2.99999 0'
        input = mesh0
        new_boundary = 'core_bottom'
        top_right = '13.00001 3.00001 0'
    []
    [fixnode]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '2.99999 2.99999 0'
        input = rollingnode
        new_boundary = 'fix_point'
        top_right = '3.00001 3.00001 0'
    []
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

[Physics]
    [SolidMechanics]
        [QuasiStatic]
            [sample]
                new_system = true
                add_variables = true
                strain = SMALL
                formulation = TOTAL
                volumetric_locking_correction = true
                generate_output = "cauchy_stress_xx cauchy_stress_yy cauchy_stress_zz
                                cauchy_stress_xy cauchy_stress_xz cauchy_stress_yz
                                mechanical_strain_xx mechanical_strain_yy mechanical_strain_zz
                                mechanical_strain_xy mechanical_strain_xz mechanical_strain_yz"
                additional_generate_output = 'vonmises_cauchy_stress'
            []
        []
    []
[]

[NEML2]
    input = 'neml2/Si_solidify.i'
    cli_args = 'Ts_low=${Ts_low} Ts_high=${Ts_high} H_latent=${H_latent}
                E=${E} mu=${mu} deltaOmega=${deltaOmega}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE      POSTPROCESSOR POSTPROCESSOR MATERIAL    MATERIAL        MATERIAL
                             MATERIAL'
        moose_inputs = '     T             time          time          q           alpha_Si        alpha_Si
                             neml2_strain'
        neml2_inputs = '     forces/T      forces/t      old_forces/t  old_state/q old_state/alpha state/alpha
                             forces/eps'

        moose_output_types = 'MATERIAL      MATERIAL   MATERIAL MATERIAL    MATERIAL'
        moose_outputs = '     f_Si_solid    qdot       q        alpha_Si    neml2_stress'
        neml2_outputs = '     state/f_solid state/qdot state/q  state/alpha state/sigma'

        moose_derivative_types = 'MATERIAL             MATERIAL'
        moose_derivatives = '     neml2_dqdotdT        neml2_dsigdeps'
        neml2_derivatives = '     state/qdot forces/T; state/sigma forces/eps'

        initialize_outputs = '      f_Si_solid  q  alpha_Si'
        initialize_output_values = 'f0_Si_solid q0 alpha_Si0'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'f0_Si_solid q0'
        prop_values = '${f0} ${q0}'
    []
    [const_mat_prop]
        type = GenericConstantMaterial
        prop_names = 'K rhocp dKdt drhocpdT'
        prop_values = '${K} ${fparse rho_Si*cp_Si} 0.0 0.0'
    []
    [alpha_Si0]
        type = ParsedMaterial
        property_name = alpha_Si0
        coupled_variables = 'phi_Si'
        expression = 'phi_Si/${omega_Si}'
    []
    [convert_strain]
        type = RankTwoTensorToSymmetricRankTwoTensor
        from = 'total_strain'
        to = 'neml2_strain'
    []
    [stress]
        type = ComputeLagrangianObjectiveCustomSymmetricStress
        custom_small_stress = 'neml2_stress'
        custom_small_jacobian = 'neml2_dsigdeps'
    []
    [convection]
        type = ADParsedMaterial
        property_name = q_boundary
        expression = 'htc*(T - (T0-dTdtcool*tcool*3600))'
        coupled_variables = T
        constant_names = 'htc T0 dTdtcool tcool'
        constant_expressions = '${htc} ${T0} ${dTdtcool} ${tcool}'
        postprocessor_names = 'time'
        boundary = 'core_sides'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
    [vintegral]
        type = ElementIntegralVariablePostprocessor
        variable = phi_Si
        execute_on = 'INITIAL TIMESTEP_END'
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
    [alpha_Si]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = alpha_Si
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phi_Si]
        order = CONSTANT
        family = MONOMIAL
    []
[]

#[AuxKernels]
#    [phi_Si]
#        type = SolutionAux
#        variable = phi_Si
#        from_variable = phi_Si
#        solution = reader_object
#        execute_on = 'INITIAL'
#    []
#[]

[UserObjects]
    [reader_object]
        type = SolutionUserObject
        mesh = '${base_folder}/core.e'
        system_variables = 'phi_Si'
        execute_on = 'INITIAL'
        timestep = 'LATEST'
    []
[]

[ICs]
    [alpha_SiIC]
        type = ConstantIC
        variable = T
        value = ${T0}
    []
    [phi_SiIC]
        type = SolutionIC
        from_variable = phi_Si
        solution_uo = reader_object
        variable = phi_Si
    []
[]

[Functions]
    [tramp]
        type = PiecewiseLinear
        x = '0 ${fparse tcool*3600}'
        y = '${T0} ${Tmin}'
    []
[]

[BCs]
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = 'core_sides'
        variable = T
        value = -1
    []
    [roller_bot]
        type = DirichletBC
        boundary = 'core_bottom'
        value = 0.0
        variable = disp_y
    []
    [fix_point_x]
        type = DirichletBC
        boundary = 'fix_point'
        value = 0.0
        variable = disp_x
    []
    [fix_point_y]
        type = DirichletBC
        boundary = 'fix_point'
        value = 0.0
        variable = disp_y
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
    file_base = '${base_folder}/solidification'
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
        file_base = '${base_folder}/solidification'
    []
    print_linear_residuals = false
[]