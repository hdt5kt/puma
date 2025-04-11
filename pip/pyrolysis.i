############### Calculations ################
# Simulation parameters
dt = 5

alpha0 = '${fparse 1/(1-Y)}' # 1/(1-Y)
invYm1 = '${fparse 1-1/Y}' # 1-1/Y

t_ramp = '${fparse (Tmax-T0)/dTdt*60}' #s
theat = '${fparse t_ramp+t_hold*3600}'
dTdtcool = '${fparse (Tmax-T0)/(tcool*3600)}' #Ks-1
total_time = '${fparse theat + tcool*3600}'

[GlobalParams]
    displacements = 'disp_x disp_y'
[]

[Mesh]
    [mesh0]
        type = FileMeshGenerator
        file = '${meshfile}'
    []
    [rollingnode]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse xroll-0.00000001} ${fparse yroll-0.00000001} ${fparse zroll-0.00000001}'
        input = mesh0
        new_boundary = 'roll'
        top_right = '${fparse xroll+0.00000001} ${fparse yroll+0.00000001} ${fparse zroll+0.00000001}'
    []
    [fixnode]
        type = BoundingBoxNodeSetGenerator
        bottom_left = '${fparse xfix-0.00000001} ${fparse yfix-0.00000001} ${fparse zfix-0.00000001}'
        input = rollingnode
        new_boundary = 'fix'
        top_right = '${fparse xfix+0.00000001} ${fparse yfix+0.00000001} ${fparse zfix+0.00000001}'
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
    cli_args = 'rho_s=${rho_s} rho_b=${rho_b} rho_g=${rho_g} rho_p=${rho_p} Mref=${Mref}
                rho_sm1M=${fparse Mref/rho_s} rho_bm1M=${fparse Mref/rho_b}
                rho_gm1M=${fparse Mref/rho_g} rho_pm1M=${fparse Mref/rho_p}
                cp_s=${cp_s} cp_b=${cp_b} cp_p=${cp_p}
                k_s=${k_s} k_b=${k_b} k_p=${k_p}
                Ea=${Ea} A=${A} R=${R} Y=${Y} invYm1=${invYm1}
                order=${order} order_k=${order_k} hrp=${hrp}
                cp_to_wg_relation=${cp_to_wg_relation} op_to_solid_relation=${op_to_solid_relation}
                alpha0=${alpha0} Tref=${Tref} E=${E} g=${g} mu=${mu}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE     POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL     MATERIAL      MATERIAL      MATERIAL        MATERIAL
                             MATERIAL' #     MATERIAL      MATERIAL      MATERIAL'
        moose_inputs = '     T            time          time          alpha           phis
                             wb           wp            ws            wgcp            phiop
                             wb           wp            ws            wgcp            phiop
                             neml2_strain' # eps_Ev        eps_Ev        Vol'
        neml2_inputs = '     forces/T     forces/tt     old_forces/tt old_state/alpha old_state/phis
                             state/wb     state/wp      state/ws      state/wgcp      state/phiop
                             old_state/wb old_state/wp  old_state/ws  old_state/wgcp  old_state/phiop
                             forces/eps' #   state/Ev      old_state/Ev    old_state/V'

        moose_parameter_types = 'MATERIAL    MATERIAL    MATERIAL       MATERIAL       MATERIAL'
        moose_parameters = '     wb0         ws0         wb0            ws0            Vref0'
        neml2_parameters = '     amount_wb0  amount_ws0  amount_new_wb0 amount_new_ws0 volume_strain_V0'

        moose_output_types = 'MATERIAL        MATERIAL   MATERIAL   MATERIAL     MATERIAL
                              MATERIAL        MATERIAL   MATERIAL   MATERIAL     MATERIAL
                              MATERIAL        MATERIAL   MATERIAL   MATERIAL
                              MATERIAL  ' #     MATERIAL'
        moose_outputs = '     wb              wp         ws         wgcp         phiop
                              phib            phip       phis       phigcp       alpha
                              alphadot        K          Vol          rhocp
                              neml2_stress ' #   eps_Ev'
        neml2_outputs = '     state/wb        state/wp   state/ws   state/wgcp   state/phiop
                              state/phib      state/phip state/phis state/phigcp state/alpha
                              state/alpha_dot state/K    state/V    state/rhocp
                              state/sigma' #    state/Ev'

        moose_derivative_types = 'MATERIAL                  MATERIAL              MATERIAL
                                  MATERIAL'
        moose_derivatives = '     neml2_dalphadotdT         neml2_drhocpdT        neml2_dKdT
                                  neml2_dsigdeps'
        neml2_derivatives = '     state/alpha_dot forces/T; state/rhocp forces/T; state/K forces/T;
                                  state/sigma forces/eps'

        initialize_outputs = '      wb  wp  ws  wgcp  phis  alpha  phiop ' # Vol     eps_Ev'
        initialize_output_values = 'wb0 wp0 ws0 wgcp0 phis0 alpha0 phiop0 ' # Vref0  eps_Ev0'
    []
[]

[Materials]
    [init_alpha]
        type = GenericConstantMaterial
        prop_names = 'alpha0 phiop0'
        prop_values = '${alpha0} 0.0'
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

[VectorPostprocessors]
    [composition_info]
        type = ElementMaterialSampler
        property = 'phiop phigcp phis phip phib ws wp wb wgcp vonmises_cauchy_stress'
        execute_on = 'FINAL'
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
    [wgcp]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = wgcp
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phib]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phib
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phip]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phip
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phis]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phis
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phigcp]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phigcp
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [phiop]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phiop
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [Vol]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = Vol
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]

[Functions]
    [temp_profile]
        type = ParsedFunction
        expression = 'if(t<t_ramp,(dTdt/60)*t_ramp,(if(t<theat, Tmax, Tmax-dTdtcool*tcool*3600)))'
        symbol_names = 't_ramp dTdt theat Tmax dTdtcool tcool'
        symbol_values = '${t_ramp} ${dTdt} ${theat} ${Tmax} ${dTdtcool} ${tcool}'
    []
[]

[BCs]
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = 'open'
        variable = T
        value = -1
    []
    [roller_bot]
        type = DirichletBC
        boundary = 'roll'
        value = 0.0
        variable = disp_y
    []
    [fix_point_x]
        type = DirichletBC
        boundary = 'fix'
        value = 0.0
        variable = disp_x
    []
    [fix_point_y]
        type = DirichletBC
        boundary = 'fix'
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
    file_base = '${save_folder}/out_cycle${cycle}'
    # console = true
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
        # execute_on = 'NONE'
        # execute_input_on = 'NONE'
        # execute_reporters_on = 'NONE'
        # outlier_variable_norms = False
    []
    [csv]
        type = CSV
        file_base = '${save_folder}/out_cycle${cycle}'
        execute_on = 'FINAL'
        create_final_symlink = true
    []
    print_linear_residuals = false
[]