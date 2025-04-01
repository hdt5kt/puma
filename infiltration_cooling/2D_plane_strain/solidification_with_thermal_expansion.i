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
rho_SiC = 3.21
rho_C = 2.26

# specifc heat # Jg-1K-1
cp_Si = 0.7
cp_SiC = 0.75
cp_C = 0.7077

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
twait = 0.1 #hours
total_time = '${fparse (twait+tcool)*3600}'

# thermal expansion coefficients (degree-1)
g = 4e-6 #solid Si 2.5e-6, graphite 1->24e-6, SiC 4e-6 so this is a reasonable value
Tref = ${T0} #K

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
    []
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
                #generate_output = "cauchy_stress_xx cauchy_stress_yy cauchy_stress_zz
                #                cauchy_stress_xy cauchy_stress_xz cauchy_stress_yz
                #                mechanical_strain_xx mechanical_strain_yy mechanical_strain_zz
                #                mechanical_strain_xy mechanical_strain_xz mechanical_strain_yz"
                additional_generate_output = 'vonmises_cauchy_stress'
            []
        []
    []
[]

[NEML2]
    input = 'neml2/Si_solidify_with_thermal_expansion.i'
    cli_args = 'Ts_low=${Ts_low} Ts_high=${Ts_high} H_latent=${H_latent}
                E=${E} mu=${mu} deltaOmega=${deltaOmega}
                omega_L=${omega_Si} rho_L=${rho_Si} rho_P=${rho_SiC} rho_S=${rho_C}
                cp_L=${cp_Si} cp_P=${cp_SiC} cp_S=${cp_C} g=${g}
                Tref=${Tref}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE      POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL        MATERIAL
                             MATERIAL      MATERIAL      MATERIAL      MATERIAL        MATERIAL'
        moose_inputs = '     T             time          time          q               alpha_Si        alpha_Si
                             neml2_strain  phi_SiC       phi_C         phi_SiC         phi_C'
        neml2_inputs = '     forces/T      forces/t      old_forces/t  old_state/q     old_state/alpha state/alpha
                             forces/eps    state/phi_P   state/phi_S   old_state/phi_P old_state/phi_S'

        moose_output_types = 'MATERIAL      MATERIAL      MATERIAL    MATERIAL        MATERIAL
                              MATERIAL      MATERIAL      MATERIAL    MATERIAL        MATERIAL'
        moose_outputs = '     f_Si_solid    qdot          q           alpha_Si        neml2_stress
                              phi_SiC       phi_C         rhocp_mat   s_thermal       s_phase'
        neml2_outputs = '     state/f_solid state/qdot    state/q     state/alpha     state/sigma
                              state/phi_P   state/phi_S   state/rhocp state/s_thermal state/s_phase'

        moose_derivative_types = 'MATERIAL             MATERIAL'
        moose_derivatives = '     neml2_dqdotdT        neml2_dsigdeps'
        neml2_derivatives = '     state/qdot forces/T; state/sigma forces/eps'

        initialize_outputs = '      f_Si_solid  q  alpha_Si  phi_SiC  phi_C'
        initialize_output_values = 'f0_Si_solid q0 alpha_Si0 phi_SiC0 phi_C0'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'f0_Si_solid q0 Hlatent'
        prop_values = '${f0} ${q0} ${H_latent}'
    []
    [const_mat_prop]
        type = GenericConstantMaterial
        prop_names = 'K rhocp dKdt drhocpdT'
        prop_values = '${K} ${fparse rho_Si*cp_Si} 0.0 0.0'
        # prop_names = 'K dKdt'
        # prop_values = '${K} 0.0'
    []
    [alpha_Si0]
        type = ParsedMaterial
        property_name = alpha_Si0
        coupled_variables = 'phi_Si'
        expression = 'phi_Si/${omega_Si}'
    []
    [phi_SiC0]
        type = ParsedMaterial
        property_name = phi_SiC0
        coupled_variables = 'phi_SiC0'
        expression = 'phi_SiC0/1.0'
    []
    [phi_C0]
        type = ParsedMaterial
        property_name = phi_C0
        coupled_variables = 'phi_C0'
        expression = 'phi_C0/1.0'
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
    [rhocp_mat]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = rhocp_mat
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phi_Si]
        order = CONSTANT
        family = MONOMIAL
    []
    [phi_SiC0]
        order = CONSTANT
        family = MONOMIAL
    []
    [phi_C0]
        order = CONSTANT
        family = MONOMIAL
    []
[]

!include strain_output.i

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
        system_variables = 'phi_Si phi_C phi_SiC'
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
    [phi_SiC0]
        type = SolutionIC
        from_variable = phi_SiC
        solution_uo = reader_object
        variable = phi_SiC0
    []
    [phi_C0]
        type = SolutionIC
        from_variable = phi_C
        solution_uo = reader_object
        variable = phi_C0
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
    file_base = '${base_folder}/solidification_total'
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
        file_base = '${base_folder}/strain/solidification_total'
    []
    print_linear_residuals = false
[]