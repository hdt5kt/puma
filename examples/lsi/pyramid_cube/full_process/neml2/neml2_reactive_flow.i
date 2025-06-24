[Solvers]
    [newton]
        type = Newton
        verbose = false
    []
[]

[Models]
    ################################################################
    ###                                                          ###
    ###                                                          ###
    ###                   CONSTITUTIVE MODEL                      ##
    ###                                                          ###
    ###                                                          ###
    ################################################################
    [outer_radius]
        type = CylindricalChannelGeometry
        solid_fraction = 'state/phis'
        product_fraction = 'state/phip'
        inner_radius = 'state/ri'
        outer_radius = 'state/ro'
    []
    [fluid_reactivity]
        type = HermiteSmoothStep
        argument = 'forces/phif'
        value = 'state/R_L'
        lower_bound = 0
        upper_bound = 0.1
    []
    [solid_reactivity]
        type = HermiteSmoothStep
        argument = 'state/phis'
        value = 'state/R_S'
        lower_bound = 0
        upper_bound = 0.1
    []
    [reaction_rate]
        type = DiffusionLimitedReaction
        diffusion_coefficient = '${D}'
        molar_volume = '${omega_Si}'
        product_inner_radius = 'state/ri'
        solid_inner_radius = 'state/ro'
        liquid_reactivity = 'state/R_L'
        solid_reactivity = 'state/R_S'
        reaction_rate = 'state/react'
    []
    [substance_product]
        type = ScalarLinearCombination
        from_var = 'state/phip'
        to_var = 'state/alpha_p'
        coefficients = '${oSiCm1}'
    []
    [substance_product_old]
        type = ScalarLinearCombination
        from_var = 'old_state/phip'
        to_var = 'old_state/alpha_p'
        coefficients = '${oSiCm1}'
    []
    [product_rate]
        type = ScalarVariableRate
        variable = 'state/alpha_p'
        rate = 'state/adot_p'
        time = 'forces/t'
    []
    [substance_solid]
        type = ScalarLinearCombination
        from_var = 'state/phis'
        to_var = 'state/alpha_s'
        coefficients = '${oCm1}'
    []
    [substance_solid_old]
        type = ScalarLinearCombination
        from_var = 'old_state/phis'
        to_var = 'old_state/alpha_s'
        coefficients = '${oCm1}'
    []
    [solid_rate]
        type = ScalarVariableRate
        variable = 'state/alpha_s'
        rate = 'state/adot_s'
        time = 'forces/t'
    []
    ### ----------------------------
    ### IVP
    ### ----------------------------
    [residual_phip]
        type = ScalarLinearCombination
        from_var = 'state/adot_p state/react'
        to_var = 'residual/phip'
        coefficients = '1.0 -1.0'
    []
    [residual_phis]
        type = ScalarLinearCombination
        from_var = 'state/adot_p state/adot_s'
        to_var = 'residual/phis'
        coefficients = '1.0 ${chem_ratio}'
    []
    [model_residual]
        type = ComposedModel
        models = "residual_phip residual_phis
                outer_radius fluid_reactivity solid_reactivity
                  reaction_rate substance_product product_rate 
                  substance_solid solid_rate
                  substance_solid_old substance_product_old"
    []
    [model_update]
        type = ImplicitUpdate
        implicit_model = 'model_residual'
        solver = 'newton'
    []
    [model_solver]
        type = ComposedModel
        models = 'model_update'
    []
    ################################################################
    ###                                                          ###
    ###                                                          ###
    ###                   POST PROCESS VALUES                     ##
    ###                                                          ###
    ###                                                          ###
    ################################################################
    ##
    ## get the source term
    ##
    [outer_radius_new]
        type = CylindricalChannelGeometry
        solid_fraction = 'state/phis'
        product_fraction = 'state/phip'
        inner_radius = 'state/ri'
        outer_radius = 'state/ro'
    []
    [fluid_reactivity_new]
        type = HermiteSmoothStep
        argument = 'forces/phif'
        value = 'state/R_L'
        lower_bound = 0
        upper_bound = 0.1
    []
    [solid_reactivity_new]
        type = HermiteSmoothStep
        argument = 'state/phis'
        value = 'state/R_S'
        lower_bound = 0
        upper_bound = 0.1
    []
    [reaction_rate_new]
        type = DiffusionLimitedReaction
        diffusion_coefficient = '${D}'
        molar_volume = '${omega_Si}'
        product_inner_radius = 'state/ri'
        solid_inner_radius = 'state/ro'
        liquid_reactivity = 'state/R_L'
        solid_reactivity = 'state/R_S'
        reaction_rate = 'state/react'
    []
    [alpha_rate]
        type = ScalarLinearCombination
        from_var = 'state/react'
        to_var = 'state/alpha_dot'
        coefficients = '${mchem_P}'
    []
    [liquid_consumption_rate]
        type = ScalarLinearCombination
        from_var = 'state/alpha_dot'
        to_var = 'state/phidotf'
        coefficients = '${omega_Si}'
    []
    [Ms]
        type = ScalarLinearCombination
        from_var = 'state/phidotf'
        to_var = 'state/Ms'
        coefficients = '${rhof}'
    []
    [void]
        type = ScalarLinearCombination
        from_var = 'state/phip state/phis forces/phif'
        to_var = 'state/poro'
        coefficients = '-1.0 -1.0 -1.0'
        constant_coefficient = 1.0
    []
    [model_Ms]
        type = ComposedModel
        models = 'Ms void alpha_rate liquid_consumption_rate
        outer_radius_new reaction_rate_new fluid_reactivity_new solid_reactivity_new'
    []
    ##
    ##
    ## solid mechanics ----------------------------------------------------------
    [Jacobian]
        type = R2Determinant
        input = 'forces/F'
        determinant = 'state/J'
    []
    [M1]
        type = ScalarLinearCombination
        coefficients = "${rho_f}"
        from_var = 'state/J'
        to_var = 'state/M1'
    []
    [no_phase_change]
        type = ScalarParameterToState
        from = 1.0
        to = 'state/c'
    []
    [fluid_F]
        type = SwellingAndPhaseChangeDeformationJacobian
        phase_fraction = 'state/c'
        swelling_coefficient = ${swelling_coef}
        jacobian = 'state/Jf'
        fluid_fraction = 'forces/phif'
    []
    # thermal add-on ###########
    [Fthermal]
        type = ThermalDeformationJacobian
        temperature = 'forces/T'
        reference_temperature = ${Tref}
        CTE = ${therm_expansion}
        jacobian = 'state/Jt'
    []
    [FFf]
        type = ScalarMultiplication
        from_var = 'state/Jt state/Jf'
        to_var = 'state/Jtotal'
    []
    # -----------------------------
    [totalF]
        type = VolumeAdjustDeformationGradient
        input = 'forces/F'
        output = 'state/Fe'
        jacobian = 'state/Jtotal'
    []
    ########
    [green_strain]
        type = GreenLagrangeStrain
        deformation_gradient = 'state/Fe'
        strain = 'state/Ee'
    []
    [S_pk2]
        type = LinearIsotropicElasticity
        strain = 'state/Ee'
        stress = 'state/pk2_SR2'
        coefficients = '${E} ${nu}'
        coefficient_types = 'YOUNGS_MODULUS POISSONS_RATIO'
    []
    [S_pk2_R2]
        type = SR2toR2
        input = 'state/pk2_SR2'
        output = 'state/pk2'
    []
    [S_pk1]
        type = R2Multiplication
        A = 'forces/F'
        B = 'state/pk2'
        to = 'state/pk1'
        invert_B = false
    []
    [model_pk1]
        type = ComposedModel
        models = 'no_phase_change fluid_F FFf
                  Fthermal totalF green_strain S_pk2 S_pk2_R2 S_pk1'
        additional_outputs = 'state/Fe state/Jf'
    []
    ############################################################
    [stress_induce_pressure]
        type = AdvectiveStress
        coefficient = '${advs_coefficient}'
        jacobian = 'state/Jf'
        deformation_gradient = 'forces/F'
        pk1_stress = 'state/pk1'
        advective_stress = 'state/Ps'
    []
    [stress_scale]
        type = ScalarMultiplication
        from_var = 'state/Ps state/Seff_cap'
        to_var = 'state/SPs'
    []
    [advective_stress]
        type = ComposedModel
        models = 'stress_scale Jacobian stress_induce_pressure'
    []
    #-------------------------------
    [model_sm]
        type = ComposedModel
        models = 'Jacobian M1 model_pk1 advective_stress'
        additional_outputs = 'state/pk1'
    []
    #################################################################
    ## porous flow -----------------------------------------------------------------
    [phinoreact]
        type = ScalarParameterToState
        from = 0.0
        to = 'state/phinoreact'
    []
    [phif_max]
        type = ScalarLinearCombination
        from_var = 'state/phip state/phis state/phinoreact'
        to_var = 'state/phif_max'
        coefficients = '-1.0 -1.0 -1.0'
        constant_coefficient = 1.0
    []
    [permeability]
        type = PowerLawPermeability
        reference_permeability = ${kk_L}
        reference_porosity = 0.9
        exponent = ${permeability_power}
        porosity = 'state/phif_max'
        permeability = 'state/perm'
    []
    [effective_saturation]
        type = EffectiveSaturation
        residual_volume_fraction = 0.00001
        flow_fraction = 'forces/phif'
        max_fraction = 'state/phif_max'
        effective_saturation = 'state/Seff_cap'
    []
    [M3]
        type = ScalarLinearCombination
        coefficients = "${rhof_nu}"
        from_var = 'state/perm'
        to_var = 'state/M3'
    []
    [M4]
        type = ScalarMultiplication
        coefficient = "${rhof2_nu}"
        from_var = 'state/perm state/Seff_cap'
        to_var = 'state/M4'
    []
    [capillary_pressure]
        type = BrooksCoreyCapillaryPressure
        threshold_pressure = '${brooks_corey_threshold}'
        power = '${capillary_pressure_power}'
        effective_saturation = 'state/Seff_cap'
        capillary_pressure = 'state/Pc'
        apply_log_extension = true
    []
    [M5]
        type = ScalarLinearCombination
        from_var = 'state/Pc state/SPs'
        to_var = 'state/M5'
        coefficients = '-1.0 1.0'
    []
    [M6]
        type = ScalarLinearCombination
        from_var = 'state/phis state/phip forces/phif state/phinoreact'
        to_var = 'state/M6'
        coefficients = '${rhocp_C} ${rhocp_SiC} ${rhocp_Si} ${rhocp_SiC}'
    []
    [model_M3456]
        type = ComposedModel
        models = 'phif_max phinoreact model_sm
        permeability effective_saturation capillary_pressure M3 M4 M5 M6
        '
        additional_outputs = 'state/perm state/phif_max'
    []
    [model]
        type = ComposedModel
        models = 'model_solver model_Ms model_M3456'
        additional_outputs = 'state/phip state/phis'
    []
[]