############### Input ################
# Simulation parameters
dt = 5

# Initial conditions
T0 = 2000 #K
Tmin = 500 #K
#alpha = 0.05 #mol/cm3

# Solidifciation Kinetics
Ts_low = 1687 #K
Ts_high = '${fparse Ts_low + 20}'
H_latent = 50555 #J mol-1

# Molar Mass # g mol-1
M_Si = 28.085

# denisty # g cm-3
rho_Si = 2.57 # density at liquid state
rho_Si_s = 2.37 # density at solid state

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

# Boundary Conditions
tcool = 0.5 #hours
dTdtcool = '${fparse (T0-Tmin)/(tcool*3600)}' #Ks-1
twait = 3 #hours
total_time = '${fparse (twait+tcool)*3600}'

#### stress-strain ####
E = 150e9
mu = 0.3

#boundary conditions
htc = 0.1 #Wcm-2K

[GlobalParams]
    displacements = 'disp_x disp_y'
[]

[Mesh]
    type = FileMesh
    file = 'gold/try_mesh.msh'
    allow_renumbering = false
    construct_side_list_from_node_list = true
    dim = 3
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
                E=${E} mu=${mu} deltaOmega=${fparse (omega_Si_s-omega_Si_l)}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE      POSTPROCESSOR POSTPROCESSOR MATERIAL    MATERIAL        MATERIAL
                             MATERIAL'
        moose_inputs = '     T             time          time          q           alpha           alpha
                             neml2_strain'
        neml2_inputs = '     forces/T      forces/t      old_forces/t  old_state/q old_state/alpha state/alpha
                             forces/eps'

        moose_output_types = 'MATERIAL      MATERIAL   MATERIAL MATERIAL    MATERIAL'
        moose_outputs = '     f_Si_solid    qdot       q        alpha       neml2_stress'
        neml2_outputs = '     state/f_solid state/qdot state/q  state/alpha state/sigma'

        moose_derivative_types = 'MATERIAL             MATERIAL'
        moose_derivatives = '     neml2_dqdotdT        neml2_dsigdeps'
        neml2_derivatives = '     state/qdot forces/T; state/sigma forces/eps'

        initialize_outputs = '      f_Si_solid q alpha'
        initialize_output_values = 'f0_Si_solid q0 alpha0'
    []
[]

[Functions]
    [poro_func]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 3
    []
[]

[UserObjects]
    [reader_object]
        type = PropertyReadFile
        prop_file_name = 'gold/porosity.csv'
        read_type = 'voronoi'
        nprop = 4 # number of columns in CSV
        nvoronoi = 2601 # number of rows that are considered
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'f0_Si_solid q0'
        prop_values = '${f0} ${q0}'
    []
    [init_poro]
        type = GenericFunctionMaterial
        prop_names = 'alpha0'
        prop_values = poro_func
    []
    [const_mat_prop]
        type = GenericConstantMaterial
        prop_names = 'K rhocp dKdt drhocpdT'
        prop_values = '${K} ${fparse rho_Si*cp_Si} 0.0 0.0'
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
        boundary = 'open'
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
    [alpha]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = alpha
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]

#[VectorPostprocessors]
#    [line]
#        type = LineValueSampler
#        end_point = '${xmax} 0 0'
#        num_points = ${nx}
#        sort_by = 'x'
#        start_point = '0 0 0'
#        variable = 'T wb wp ws vb vp vs vv'
#    []
#[]

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
        x = '0 ${fparse tcool*3600}'
        y = '${T0} ${Tmin}'
    []
[]

[BCs]
    #[boundary]
    #    type = FunctionDirichletBC
    #    boundary = 'top right'
    #    variable = T
    #    function = temp_profile
    #[]
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = open
        variable = T
        value = -1
    []
    [roller_left]
        type = DirichletBC
        boundary = left
        value = 0.0
        variable = disp_x
    []
    [roller_bot]
        type = DirichletBC
        boundary = bottom
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
    dtmax = '${fparse 12*dt}'

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
        file_base = 'heating_and_cooling/out'
    []
    print_linear_residuals = false
[]