[Models]
    ## solidifications ----------------------------------------------------------
    [liquid_phase_portion]
        type = HermiteSmoothStep
        argument = 'forces/T'
        value = 'state/cliquid'
        lower_bound = '${Ts}'
        upper_bound = '${Tf}'
        complement_condition = false
    []
    [solid_phase_portion]
        type = ScalarLinearCombination
        from_var = 'state/cliquid'
        to_var = 'state/omcliquid'
        coefficients = -1.0
        constant_coefficient = 1.0
    []
    [liquid_phase_fluid]
        type = ScalarMultiplication
        from_var = 'state/cliquid forces/phif'
        to_var = 'state/phif_l'
    []
    [solid_phase_fluid]
        type = ScalarMultiplication
        from_var = 'state/omcliquid forces/phif'
        to_var = 'state/phif_s'
    []
    [phase_regularization]
        type = SymmetricHermiteInterpolation
        argument = 'forces/T'
        value = 'state/eta'
        lower_bound = '${Ts}'
        upper_bound = '${Tf}'
    []
    [Tdot]
        type = ScalarVariableRate
        variable = 'forces/T'
        rate = 'forces/Tdot0'
        time = 'forces/t'
    []
    [Tdot0]
        type = ScalarLinearCombination
        from_var = 'forces/Tdot0'
        to_var = 'state/Tdot'
        constant_coefficient = 0.0001
    []
    [M10]
        type = ScalarMultiplication
        from_var = 'state/eta state/J state/Tdot'
        to_var = 'state/M10'
        coefficient = '${mrhofL}'
    []
    [model_solidification]
        type = ComposedModel
        models = 'Tdot0 Jacobian liquid_phase_portion solid_phase_portion liquid_phase_fluid solid_phase_fluid
                    phase_regularization Tdot M10'
        additional_outputs = 'state/cliquid state/omcliquid'
    []
    ## solid mechanics ----------------------------------------------------------
    [Jacobian]
        type = DeformationGradientJacobian
        deformation_gradient = 'forces/F'
        jacobian = 'state/J'
    []
    [M1]
        type = ScalarMultiplication
        coefficient = "${rho_f}"
        from_var = 'state/J state/cliquid'
        to_var = 'state/M1'
    []
    [fluid_F]
        type = PhaseChangeDeformationGradient
        phase_fraction = 'state/cliquid'
        CPE = '${swelling_coef}'
        deformation_gradient = 'state/Ff'
        fluid_fraction = 'forces/phif'
        inverse_condition = true
    []
    [FFf]
        type = R2Multiplication
        A = 'forces/F'
        B = 'state/Ff'
        to = 'state/FFf'
        invert_B = false
    []
    # thermal add-on ###########
    [Fthermal]
        type = ThermalDeformationGradient
        temperature = 'forces/T'
        reference_temperature = ${Tref}
        CTE = ${therm_expansion}
        deformation_gradient = 'state/Ft'
        inverse_condition = true
    []
    # -----------------------------
    [totalF]
        type = R2Multiplication
        A = 'state/FFf'
        B = 'state/Ft'
        to = 'state/Fe'
        invert_B = false
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
        coefficients = '1000 ${nu}'
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
        models = 'fluid_F FFf
                  Fthermal totalF green_strain S_pk2 S_pk2_R2 S_pk1'
        additional_outputs = 'state/Fe'
    []
    [model_sm]
        type = ComposedModel
        models = 'Jacobian M1 model_pk1'
    []
    ############################################################
    [stress_induce_pressure]
        type = AdvectionStress
        coefficient = '${advs_coefficient}'
        jacobian = 'state/J'
        deformation_gradient = 'state/Fe'
        pk1_stress = 'state/pk1'
        average_advection_stress = 'state/Ps'
    []
    [stress_scale]
        type = ScalarMultiplication
        from_var = 'state/Ps state/Seff_cap'
        to_var = 'state/SPs'
    []
    [advective_stress]
        type = ComposedModel
        models = 'model_pk1 stress_scale Jacobian stress_induce_pressure'
    []
    #################################################################
    ## porous flow -----------------------------------------------------------------
    [phisp]
        type = ScalarParameterToState
        from = 1.0
        to = 'state/phisp'
    []
    [phifmax]
        type = ScalarLinearCombination
        from_var = 'state/phisp state/phif_s'
        to_var = 'state/phif_max'
        coefficients = '-1.0 -1.0'
        constant_coefficient = 1.0
    []
    [permeability]
        type = PowerLawPermeability
        reference_permeability = ${kk_L}
        reference_porosity = 0.9
        power = ${permeability_power}
        porosity = 'state/phif_max'
        permeability = 'state/perm'
    []
    [M2]
        type = ScalarMultiplication
        coefficient = "${Drho_f}"
        from_var = 'state/cliquid'
        to_var = 'state/M2'
    []
    [M3]
        type = ScalarLinearCombination
        coefficients = "${rhof_nu}"
        from_var = 'state/perm'
        to_var = 'state/M3'
    []
    [M8]
        type = ScalarLinearCombination
        coefficients = "${hf_rhof_nu}"
        from_var = 'state/perm'
        to_var = 'state/M8'
    []
    [M4]
        type = ScalarMultiplication
        coefficient = "${rhof2_nu}"
        from_var = 'state/perm state/Seff'
        to_var = 'state/M4'
    []
    [M9]
        type = ScalarLinearCombination
        coefficients = "${hf_rhof2_nu}"
        from_var = 'state/perm state/Seff_cap'
        to_var = 'state/M9'
    []
    [effective_saturation]
        type = EffectiveSaturation
        residual_volume_fraction = 0.0001
        flow_fraction = 'state/phif_l'
        max_fraction = 'state/phif_max'
        effective_saturation = 'state/Seff'
    []
    [Seff_cap]
        type = HermiteSmoothStep
        argument = 'state/phif_l'
        value = 'state/Seff_cap'
        lower_bound = '0'
        upper_bound = '0.1'
    []
    [capillary_pressure]
        type = BrooksCoreyPressure
        threshold_pressure = '${brooks_corey_threshold}'
        power = '${capillary_pressure_power}'
        effective_saturation = 'state/Seff'
        capillary_pressure = 'state/Pc'
        apply_log_extension = true
    []
    [M5]
        type = ScalarLinearCombination
        from_var = 'state/Pc state/SPs'
        to_var = 'state/M5'
        coefficients = '-1.0 -1.0'
    []
    [model_porousflow]
        type = ComposedModel
        models = 'Seff_cap phisp phifmax permeability
                    effective_saturation capillary_pressure M2 M3 M4 M5 M8 M9
                    advective_stress'
        additional_outputs = 'state/perm state/phif_max'
    []
    [model]
        type = ComposedModel
        models = 'model_sm model_porousflow model_solidification'
        additional_outputs = 'state/phif_s state/phif_l'
    []
[]