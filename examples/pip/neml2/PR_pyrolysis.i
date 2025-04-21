[Solvers]
    [newton]
        type = Newton
        rel_tol = 1e-8
        abs_tol = 1e-10
        max_its = 100
        verbose = false
    []
[]

[Models]
    ################ residual term associated with wbs
    [amount]
        type = PyrolysisConversionAmount
        initial_solid_mass_fraction = 1.0
        initial_binder_mass_fraction = 1.0
        reaction_yield = '${Y}'

        solid_mass_fraction = 'state/ws'
        reaction_amount = 'state/alpha'
    []
    [reaction]
        type = ChemicalReactionMechanism
        scaling_constant = '${order_k}'
        reaction_order = '${order}'
        reaction_amount = 'state/alpha'
        reaction_out = 'state/f'
    []
    [pyrolysis]
        type = PyrolysisKinetics
        kinetic_constant = '${A}'
        activation_energy = '${Ea}'
        ideal_gas_constant = '${R}'
        temperature = 'forces/T'
        reaction = 'state/f'
        out = 'state/pyro'
    []
    [amount_rate]
        type = ScalarVariableRate
        variable = 'state/alpha'
        time = 'forces/tt'
        rate = 'state/alpha_dot'
    []
    [residual_ms]
        type = ScalarLinearCombination
        coefficients = "1.0 -1.0"
        from_var = 'state/alpha_dot state/pyro'
        to_var = 'residual/ws'
    []
    [rws]
        type = ComposedModel
        models = 'amount reaction pyrolysis amount_rate residual_ms'
    []
    ################ residual term associated with wb
    [solid_rate]
        type = ScalarVariableRate
        variable = 'state/ws'
        time = 'forces/tt'
        rate = 'state/ws_dot'
    []
    [binder_rate]
        type = ScalarVariableRate
        variable = 'state/wb'
        time = 'forces/tt'
        rate = 'state/wb_dot'
    []
    [residual_binder]
        type = ScalarLinearCombination
        coefficients = "${Y} 1.0"
        from_var = 'state/wb_dot state/ws_dot'
        to_var = 'residual/wb'
    []
    [rwb]
        type = ComposedModel
        models = 'solid_rate binder_rate residual_binder'
    []
    ################ residual term associated with wp
    [rwp]
        type = ScalarVariableRate
        variable = 'state/wp'
        time = 'forces/tt'
        rate = 'residual/wp'
    []
    ################ residual term associated with wg_cp
    ## (closed pores gas mass fraction)
    [gas_close_pores_rate]
        type = ScalarVariableRate
        variable = 'state/wgcp'
        time = 'forces/tt'
        rate = 'state/wgcp_dot'
    []
    [mass_balance]
        type = ScalarLinearCombination
        coefficients = '-1.0'
        from_var = 'state/wb_dot state/ws_dot' #particle_dot = 0
        to_var = 'state/wg_dot'
    []
    [residual_gas]
        type = ScalarLinearCombination
        coefficients = "-1.0 ${cp_to_wg_relation}"
        from_var = 'state/wgcp_dot state/wg_dot'
        to_var = 'residual/wgcp'
    []
    [rwgcp]
        type = ComposedModel
        models = 'gas_close_pores_rate mass_balance binder_rate solid_rate residual_gas'
    []
    ################ residual term associated with vfop
    [V_RVE]
        type = PyrolysisVolume
        density_binder = '${rho_b}'
        density_solid = '${rho_s}'
        density_particle = '${rho_p}'
        density_closed_pore_gas = '${rho_g}'
        reference_mass = '${Mref}'
        binder_mass_fraction = 'state/wb'
        solid_mass_fraction = 'state/ws'
        particle_mass_fraction = 'state/wp'
        close_pore_gas_mass_fraction = 'state/wgcp'
        open_pore_volume_fraction = 'state/phiop'
        pyrolysis_composite_volume = 'state/V'
    []
    [open_pores_volume_rate]
        type = ScalarVariableRate
        variable = 'state/phiop'
        time = 'forces/tt'
        rate = 'state/phiop_dot'
    []
    [solid_volume_fraction]
        type = ScalarVariableMultiplication
        from_var = 'state/ws state/V'
        constant_coefficient = '${rho_sm1M} 1.0'
        to_var = 'state/phis'
        reciprocal = 'false true'
    []
    [solid_volume_rate]
        type = ScalarVariableRate
        variable = 'state/phis'
        time = 'forces/tt'
        rate = 'state/phis_dot'
    []
    [residual_op]
        type = ScalarLinearCombination
        coefficients = '-1.0 ${op_to_solid_relation}'
        from_var = 'state/phiop_dot state/phis_dot'
        to_var = 'residual/phiop'
    []
    [rphiop]
        type = ComposedModel
        models = 'V_RVE open_pores_volume_rate solid_volume_fraction solid_volume_rate residual_op'
    []
    ################ residual term associated with volumetric strain rate
    #[volume_rate]
    #    type = ScalarVariableRate
    #    variable = 'state/V'
    #    time = 'forces/tt'
    #    rate = 'state/Vdot'
    #[]
    #[volume_strain_rate]
    #    type = ScalarVolumeChangeEigenstrainRate
    #    volume = 'state/V'
    #    volume_rate = 'state/Vdot'
    #    eigenstrain = 'state/Ev'
    #    eigenstrain_rate = 'state/eigen_volume_rate'
    #[]
    #[Ev_rate]
    #    type = ScalarVariableRate
    #    variable = 'state/Ev'
    #    time = 'forces/tt'
    #    rate = 'state/Ev_dot'
    #[]
    #[residual_Ev]
    #    type = ScalarLinearCombination
    #    coefficients = '1.0 -1.0'
    #    from_var = 'state/Ev_dot state/eigen_volume_rate'
    #    to_var = 'residual/Ev'
    #[]
    #[rEv]
    #    type = ComposedModel
    #    models = 'V_RVE volume_rate volume_strain_rate Ev_rate residual_Ev'
    #[]
    ##########################################################################
    [model_residual]
        type = ComposedModel
        models = 'rwp rws rwb rwgcp rphiop' # rEv'
        automatic_scaling = true
    []
    [model_update]
        type = ImplicitUpdate
        implicit_model = 'model_residual'
        solver = 'newton'
    []
    [amount_new]
        type = PyrolysisConversionAmount
        initial_solid_mass_fraction = 1.0
        initial_binder_mass_fraction = 1.0
        reaction_yield = '${Y}'

        solid_mass_fraction = 'state/ws'
        reaction_amount = 'state/alpha'
    []
    [amount_rate_new]
        type = ScalarVariableRate
        variable = 'state/alpha'
        time = 'forces/tt'
        rate = 'state/alpha_dot'
    []
    [model_solver]
        type = ComposedModel
        models = 'model_update amount_new amount_rate_new'
        additional_outputs = 'state/alpha state/ws'
    []
    ################################### POST PROCESS #################################
    #########
    ############### volume fraction ######
    [V_RVE_post]
        type = PyrolysisVolume
        density_binder = '${rho_b}'
        density_solid = '${rho_s}'
        density_particle = '${rho_p}'
        density_closed_pore_gas = '${rho_g}'
        reference_mass = '${Mref}'
        binder_mass_fraction = 'state/wb'
        solid_mass_fraction = 'state/ws'
        particle_mass_fraction = 'state/wp'
        close_pore_gas_mass_fraction = 'state/wgcp'
        open_pore_volume_fraction = 'state/phiop'
        pyrolysis_composite_volume = 'state/V'
    []
    [phi_b]
        type = ScalarVariableMultiplication
        from_var = 'state/wb state/V'
        constant_coefficient = '${rho_bm1M} 1.0'
        to_var = 'state/phib'
        reciprocal = 'false true'
    []
    [phi_s]
        type = ScalarVariableMultiplication
        from_var = 'state/ws state/V'
        constant_coefficient = '${rho_sm1M} 1.0'
        to_var = 'state/phis'
        reciprocal = 'false true'
    []
    [phi_p]
        type = ScalarVariableMultiplication
        from_var = 'state/wp state/V'
        constant_coefficient = '${rho_pm1M} 1.0'
        to_var = 'state/phip'
        reciprocal = 'false true'
    []
    [phi_gcp]
        type = ScalarVariableMultiplication
        from_var = 'state/wgcp state/V'
        constant_coefficient = '${rho_gm1M} 1.0'
        to_var = 'state/phigcp'
        reciprocal = 'false true'
    []
    [phi_out]
        type = ComposedModel
        models = 'V_RVE_post phi_b phi_s phi_p phi_gcp'
        additional_outputs = 'state/V'
    []
    #########
    ######### element properties
    [rho]
        type = ScalarLinearCombination
        coefficients = '${rho_p} ${rho_b} ${rho_s}'
        from_var = 'state/phip state/phib state/phis'
        to_var = 'state/rho'
    []
    [cp]
        type = ScalarLinearCombination
        coefficients = '${cp_p} ${cp_b} ${cp_s}'
        from_var = 'state/wp state/wb state/ws'
        to_var = 'state/cp'
    []
    [rhocp]
        type = ScalarVariableMultiplication
        from_var = 'state/rho state/cp'
        to_var = 'state/rhocp'
    []
    [K]
        type = ScalarLinearCombination
        coefficients = '${k_p} ${k_b} ${k_s}'
        from_var = 'state/phip state/phib state/phis'
        to_var = 'state/K'
    []
    [elout]
        type = ComposedModel
        models = 'phi_out rho cp rhocp K'
        additional_outputs = 'state/phib state/phip state/phis'
    []
    #########
    ######### stress-strain relation
    [thermal_strain]
        type = ThermalEigenstrain
        reference_temperature = '${Tref}'
        temperature = 'forces/T'
        CTE = '${g}'
        eigenstrain = 'forces/Et'
    []
    [volume_strain]
        #type = ScalartoDiagSR2
        #input = 'state/Ev'
        #output = 'forces/EvSR2'
        type = VolumeChangeEigenstrain
        volume = 'state/V'
        reference_volume = 1.0
        eigenstrain = 'forces/EvSR2'
    []
    [elastic_strain]
        type = SR2LinearCombination
        coefficients = '1.0 -1.0 -1.0'
        from_var = 'forces/eps forces/Et forces/EvSR2'
        to_var = 'state/eps_total'
    []
    [stress_strain]
        type = LinearIsotropicElasticity
        strain = 'state/eps_total'
        stress = 'state/sigma'
        coefficients = '${E} ${mu}'
        coefficient_types = 'YOUNGS_MODULUS POISSONS_RATIO'
    []
    [ssout]
        type = ComposedModel
        models = 'thermal_strain elastic_strain stress_strain volume_strain V_RVE'
    []
    #######################################################################################
    [model]
        type = ComposedModel
        models = 'model_solver elout ssout'
        additional_outputs = 'state/wb state/ws state/wp state/wgcp state/phiop' # state/Ev'
    []
    #######################################################################################
[]