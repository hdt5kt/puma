[Models]
    ## solid mechanics ----------------------------------------------------------
    [Jacobian]
        type = R2Determinant
        input = 'forces/F'
        determinant = 'state/J'
    []
    [M1]
        type = ScalarLinearCombination
        coefficients = '${rho_f}'
        from_var = 'state/J'
        to_var = 'state/M1'
    []
    [fluid_F]
        type = SwellingAndPhaseChangeDeformationJacobian
        phase_fraction = 1.0
        swelling_coefficient = '${swelling_coefficient}'
        reference_volume_difference = 0.0
        jacobian = 'state/Jf'
        fluid_fraction = 'forces/phif'
    []
    [total_F]
        type = VolumeAdjustDeformationGradient
        input = 'forces/F'
        output = 'state/Fe'
        jacobian = 'state/Jf'
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
        models = 'fluid_F total_F
         green_strain S_pk2 S_pk2_R2 S_pk1'
    []
    [model_sm]
        type = ComposedModel
        models = 'model_pk1'
    []
    ############################################################
    [stress_induce_pressure]
        type = AdvectiveStress
        coefficient = 10.0 #'${swelling_coefficient}'
        js = 'state/Jf'
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
        models = 'model_pk1 fluid_F stress_scale stress_induce_pressure'
    []
    #################################################################
    ## porous flow -----------------------------------------------------------------
    [phif_max]
        type = ScalarParameterToState
        from = 1.0
        to = 'state/phif_max'
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
        residual_saturation = 0.0001
        fluid_fraction = 'forces/phif'
        max_fraction = 'state/phif_max'
        effective_saturation = 'state/Seff'
    []
    [Seff_cap]
        type = HermiteSmoothStep
        argument = 'forces/phif'
        value = 'state/Seff_cap'
        lower_bound = '0'
        upper_bound = '0.1'
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
       [capillary_pressure]
        type = BrooksCoreyCapillaryPressure
        threshold_pressure = '${brooks_corey_threshold}'
        exponent = '${capillary_pressure_power}'
        effective_saturation = 'state/Seff'
        capillary_pressure = 'state/Pc'
        log_extension = true
        transition_saturation = 0.1
    []
    [M5]
        type = ScalarLinearCombination
        from_var = 'state/Pc state/SPs'
        to_var = 'state/M5'
        coefficients = '-1.0 1.0'
    []
    [empty_porosity]
        type = ScalarLinearCombination
        from_var = 'state/phif_max forces/phif'
        to_var = 'state/poro'
        coefficients = '1.0 -1.0'
    []
    [solid_fraction]
        type = ScalarLinearCombination
        from_var = 'state/phif_max'
        to_var = 'state/solid'
        constant_coefficient = 1.0
        coefficients = '-1.0'
    []
    [model_porousflow]
        type = ComposedModel
        models = 'Jacobian M1 Seff_cap solid_fraction empty_porosity phif_max permeability
                    effective_saturation capillary_pressure M3 M4 M5
                    advective_stress'
        additional_outputs = 'state/perm'
    []
    [model]
        type = ComposedModel
        models = 'model_sm model_porousflow'
    []
[]