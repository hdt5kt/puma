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
    [phase_regularization]
        type = SymmetricHermiteInterpolation
        argument = 'forces/T'
        value = 'state/eta'
        lower_bound = '${Ts}'
        upper_bound = '${Tf}'
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
    [rhocp]
        type = ScalarLinearCombination
        from_var = 'state/phif_l state/phif_s'
        to_var = 'state/rhocp'
        coefficients = '${cp_rho_Si} ${cp_rho_Si_s}'
    []
    [solidification_model]
        type = ComposedModel
        models = 'liquid_phase_portion solid_phase_portion
                    liquid_phase_fluid solid_phase_fluid
                    phase_regularization rhocp'
        additional_outputs = 'state/cliquid state/omcliquid state/phif_l state/phif_s'
    []
    ## solid mechanics ----------------------------------------------------------
    [fluid_F]
        type = SwellingAndPhaseChangeDeformationJacobian
        phase_fraction = 'state/cliquid'
        swelling_coefficient = '${swelling_coef}'
        reference_volume_difference = '${dOmega_f}'
        jacobian = 'state/Jf'
        fluid_fraction = 'forces/phif'
        # type = ScalarMultiplication
        # from_var = 'forces/phif forces/T'
        # to_var = 'state/Jf'
        # coefficient = 0.0000001
    []
    # thermal add-on ###########
    [Fthermal]
        type = ThermalDeformationJacobian
        temperature = 'forces/T'
        reference_temperature = ${Tref}
        CTE = ${therm_expansion}
        jacobian = 'state/Jt'
    []
    # -----------------------------
    [Jtotal]
        type = ScalarMultiplication
        from_var = 'state/Jt state/Jf'
        to_var = 'state/Jtotal'
    []
    [totalF]
        type = VolumeAdjustDeformationGradient
        input = 'forces/F'
        output = 'state/Fe'
        jacobian = 'state/Jtotal'
    []
    [green_strain]
        type = GreenLagrangeStrain
        deformation_gradient = 'state/Fe'
        strain = 'state/Ee'
    []
    [S_pk2]
        type = LinearIsotropicElasticity
        strain = 'state/Ee'
        stress = 'state/pk2_SR2'
        coefficients = '${E} 0.3'
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
    [model_sm]
        type = ComposedModel
        models = 'fluid_F Jtotal
                  Fthermal totalF green_strain S_pk2 S_pk2_R2 S_pk1'
        additional_outputs = 'state/Fe state/Jf state/Jt'
    []
    ## porous flow ----------------------------------------------------------
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
    [effective_saturation]
        type = EffectiveSaturation
        residual_saturation = 0.0
        fluid_fraction = 'forces/phif'
        max_fraction = 'state/phif_max'
        effective_saturation = 'state/Seff'
    []
    [permeability]
        type = PowerLawPermeability
        reference_permeability = ${kk_L}
        reference_porosity = 0.9
        exponent = ${permeability_power}
        porosity = 'state/phif_max'
        permeability = 'state/perm'
    []
    [capillary_pressure]
        type = BrooksCoreyCapillaryPressure
        threshold_pressure = '${brooks_corey_threshold}'
        exponent = '${capillary_pressure_power}'
        effective_saturation = 'state/Seff'
        capillary_pressure = 'state/Pc'
        log_extension = true
        transition_saturation = 0.1
    []
    [stress_induce_pressure]
        type = AdvectiveStress
        coefficient = '${swelling_coef}'
        js = 'state/Jf'
        jt = 'state/Jt'
        deformation_gradient = 'forces/F'
        pk1_stress = 'state/pk1'
        advective_stress = 'state/Ps'
    []
    [stress_scale]
        type = ScalarMultiplication
        from_var = 'state/Ps state/Seff'
        to_var = 'state/SPs'
    []
    [advective_stress]
        type = ComposedModel
        models = ' stress_scale stress_induce_pressure'
    []
    [model_darcy]
        type = ComposedModel
        models = 'effective_saturation capillary_pressure permeability phisp phifmax
                    advective_stress'
        additional_outputs = 'state/Seff state/perm state/phif_max'
    []
    ### Material model ----------------------------------------------------------
    [Jacobian]
        type = R2Determinant
        input = 'forces/F'
        determinant = 'state/J'
    []
    [Tdot]
        type = ScalarVariableRate
        variable = 'forces/T'
        rate = 'state/Tdot'
        time = 'forces/t'
    []
    [M1]
        type = ScalarMultiplication
        coefficient = '${rho_f}'
        from_var = 'state/J state/cliquid'
        to_var = 'state/M1'
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
    [M4]
        type = ScalarMultiplication
        coefficient = "${rhof2_nu}"
        from_var = 'state/perm state/Seff'
        to_var = 'state/M4'
    []
    [M5]
        type = ScalarLinearCombination
        from_var = 'state/Pc state/SPs'
        to_var = 'state/M5'
        coefficients = '-1.0 1.0'
    []
    [M6]
        type = ScalarMultiplication
        coefficient = 1.0
        from_var = 'state/J state/rhocp'
        to_var = 'state/M6'
    []
    [M8]
        type = ScalarLinearCombination
        coefficients = "${hf_rhof_nu}"
        from_var = 'state/perm'
        to_var = 'state/M8'
    []
    [M9]
        type = ScalarLinearCombination
        coefficients = "${hf_rhof2_nu}"
        from_var = 'state/perm state/Seff'
        to_var = 'state/M9'
    []
    [M10]
        type = ScalarMultiplication
        from_var = 'state/eta state/Tdot state/J'
        to_var = 'state/M10'
        coefficient = '${mL}'
    []
    [solid_portion]
        type = ScalarLinearCombination
        coefficients = '-1.0'
        from_var = 'state/phif_max'
        to_var = 'state/solidp'
        constant_coefficient = 1.0
    []
    [materials]
        type = ComposedModel
        models = 'phisp phifmax Jacobian Tdot M1 M2 M3 M4 M5 M6 M8 M9 M10 solid_portion'
    []
    ############################################################
    [model]
        type = ComposedModel
        models = 'model_sm model_darcy solidification_model materials'
        additional_outputs = 'state/phif_s state/phif_l state/perm state/pk1'
    []
[]