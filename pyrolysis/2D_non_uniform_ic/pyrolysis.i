############### Input ################
# Simulation parameters
dt = 5

# denisty kgm-3
rho_s = 2260
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
Ea = 41220 # J mol-1
A = 1.24e4 # s-1
R = 8.31446261815324 # JK-1mol-1
hrp = 1.58e6 #e6 J kg-1
factor = 1.0

Y = 0.56
Ym1 = '${fparse 1/Y}' # 1/Y
invYm1 = '${fparse 1-1/Y}' # 1-1/Y

order = 1.0
order_k = 1.0

# initial condition #kg
alpha0 = '${fparse 1/(1-Y)}' # 1/(1-Y)

T0 = 300 #K
Tmax = 1000 #K
Tref = 300 #K

dTdt = 20 #Kmin-1 heating rate
t_ramp = '${fparse (Tmax-T0)/dTdt*60}' #s
t_hold = 3 #hrs
theat = '${fparse t_ramp+t_hold*3600}'
tcool = 3 #hrs
dTdtcool = '${fparse (Tmax-T0)/(tcool*3600)}' #Ks-1

total_time = '${fparse theat + tcool*3600}'

#### stress-strain ####
E = 400e9
mu = 0.3

# thermal expansion coefficients (degree-1)
g = 4e-6

#boundary conditions
htc = 200 #Wm-2K assume air doesnt move much

[GlobalParams]
    displacements = 'disp_x disp_y'
[]

[Mesh]
    type = FileMesh
    file = 'gold/mesh_part.msh'
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
    input = 'neml2/PR_pyrolysis.i'
    cli_args = 'rho_s=${rho_s} rho_b=${rho_b} rho_g=${rho_g} rho_p=${rho_p}
                rho_sm1=${rho_sm1} rho_bm1=${rho_bm1} rho_gm1=${rho_gm1} rho_pm1=${rho_pm1}
                cp_s=${cp_s} cp_b=${cp_b} cp_g=${cp_g} cp_p=${cp_p}
                k_s=${k_s} k_b=${k_b} k_g=${k_g} k_p=${k_p}
                Ea=${Ea} A=${A} R=${R} Y=${Y} Ym1=${Ym1} invYm1=${invYm1}
                order=${order} order_k=${order_k}
                alpha0=${alpha0}
                E=${E} mu=${mu} g=${g} Tref=${Tref}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE     POSTPROCESSOR POSTPROCESSOR MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL'
        moose_inputs = '     T            time          time          alpha
                             mb           mg            mp            ms              Vv
                             mb           mg            mp            ms              Vv
                             neml2_strain mbo           mso           Vo              mbo
                             mso          Vo'
        neml2_inputs = '     forces/T     forces/tt     old_forces/tt old_state/alpha
                             state/mb     state/mg      state/mp      state/ms        state/Vv
                             old_state/mb old_state/mg  old_state/mp  old_state/ms    old_state/Vv
                             forces/eps   old_state/mb0 old_state/ms0 old_state/V0    state/mb0
                             state/ms0    state/V0'

        moose_parameter_types = 'MATERIAL       MATERIAL       MATERIAL'
        moose_parameters = '     ms0            mb0            V0'
        neml2_parameters = '     amount_ms0     amount_mb0     volume_strain_V0'

        moose_output_types = 'MATERIAL      MATERIAL  MATERIAL  MATERIAL
                              MATERIAL      MATERIAL  MATERIAL  MATERIAL    MATERIAL
                              MATERIAL      MATERIAL  MATERIAL  MATERIAL
                              MATERIAL      MATERIAL  MATERIAL  MATERIAL
                              MATERIAL      MATERIAL  MATERIAL  MATERIAL    MATERIAL
                              MATERIAL'
        moose_outputs = '     mp            mb        mg        ms
                              wp            wb        ws        alpha       alphadot
                              vp            vb        vv        vs
                              Vp            Vb        Vv        Vs
                              K             V         rho       cp          rhocp
                              neml2_stress'
        neml2_outputs = '     state/mp      state/mb  state/mg  state/ms
                              state/wp      state/wb  state/ws  state/alpha state/alpha_dot
                              state/vp      state/vb  state/vv  state/vs
                              state/Vp      state/Vb  state/Vv  state/Vs
                              state/K       state/V   state/rho state/cp    state/rhocp
                              state/sigma'

        moose_derivative_types = 'MATERIAL                  MATERIAL              MATERIAL
                                  MATERIAL'
        moose_derivatives = '     neml2_dalphadotdT         neml2_drhocpdT        neml2_dKdT
                                  neml2_dsigdeps'
        neml2_derivatives = '     state/alpha_dot forces/T; state/rhocp forces/T; state/K forces/T;
                                  state/sigma forces/eps'

        initialize_outputs = '      mp  mb  mg  ms  alpha  Vv  mso mbo Vo'
        initialize_output_values = 'mp0 mb0 mg0 ms0 alpha0 Vv0 ms0 mb0 V0'
    []
[]

[Materials]
    [init_alpha]
        type = GenericConstantMaterial
        prop_names = 'alpha0'
        prop_values = '${alpha0}'
    []
    [init_mb]
        type = GenericFunctionMaterial
        prop_names = 'mb0'
        prop_values = mb0
    []
    [init_mp]
        type = GenericFunctionMaterial
        prop_names = 'mp0'
        prop_values = mp0
    []
    [init_mg]
        type = GenericFunctionMaterial
        prop_names = 'mg0'
        prop_values = mg0
    []
    [init_ms]
        type = GenericFunctionMaterial
        prop_names = 'ms0'
        prop_values = ms0
    []
    [init_Vvoid]
        type = GenericFunctionMaterial
        prop_names = 'Vv0'
        prop_values = Vvoid
    []
    [init_V]
        type = GenericFunctionMaterial
        prop_names = 'V0'
        prop_values = V0
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
        expression = 'htc*(T - if(time<t_ramp,(dTdt/60)*t_ramp,(if(time<theat, Tmax, Tmax-dTdtcool*tcool*3600))))'
        coupled_variables = T
        constant_names = 'htc t_ramp dTdt theat Tmax dTdtcool tcool'
        constant_expressions = '${htc} ${t_ramp} ${dTdt} ${theat} ${Tmax} ${dTdtcool} ${tcool}'
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

[ICs]
    [alphaIC]
        type = ConstantIC
        variable = T
        value = ${T0}
    []
[]

[Functions]
    [temp_profile]
        #type = PiecewiseLinear
        #x = '0 ${t_ramp}'
        #y = '${T0} ${Tmax}'
        type = ParsedFunction
        expression = 'if(t<t_ramp,(dTdt/60)*t_ramp,(if(t<theat, Tmax, Tmax-dTdtcool*tcool*3600)))'
        symbol_names = 't_ramp dTdt theat Tmax dTdtcool tcool'
        symbol_values = '${t_ramp} ${dTdt} ${theat} ${Tmax} ${dTdtcool} ${tcool}'
    []
    [mb0]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 3
    []
    [mp0]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 4
    []
    [ms0]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 5
    []
    [mg0]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 6
    []
    [Vvoid]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 7
    []
    [V0]
        type = PiecewiseConstantFromCSV
        read_prop_user_object = reader_object
        read_type = 'voronoi'
        column_number = 8
    []
[]

[UserObjects]
    [reader_object]
        type = PropertyReadFile
        prop_file_name = 'gold/initial_mass.csv'
        read_type = 'voronoi'
        nprop = 9 # number of columns in CSV
        nvoronoi = 2601 # number of rows that are considered
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
        boundary = 'open'
        variable = T
        value = -1
    []
    [roller_left]
        type = DirichletBC
        boundary = 'left'
        value = 0.0
        variable = disp_x
    []
    [roller_bot]
        type = DirichletBC
        boundary = 'bottom'
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
    dtmax = '${fparse 20*dt}'

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
        file_base = 'heating_and_cooling_nonuniform/out'
    []
    print_linear_residuals = false
[]