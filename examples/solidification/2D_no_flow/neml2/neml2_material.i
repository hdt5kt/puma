[Models]
    ## solidifications ----------------------------------------------------------
    [phif]
        type = ScalarParameterToState
        from = 1.0
        to = 'state/phif'
    []
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
    [Tdot]
        type = ScalarVariableRate
        variable = 'forces/T'
        rate = 'state/Tdot'
        time = 'forces/t'
    []
    [heatrelease]
        type = ScalarMultiplication
        from_var = 'state/eta state/J'
        to_var = 'state/M3'
        coefficient = '${mL}'
    []
    [liquid_phase_fluid]
        type = ScalarMultiplication
        from_var = 'state/cliquid state/phif'
        to_var = 'state/phif_l'
    []
    [solid_phase_fluid]
        type = ScalarMultiplication
        from_var = 'state/omcliquid state/phif'
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
        models = 'Jacobian phif liquid_phase_portion solid_phase_portion
                    liquid_phase_fluid solid_phase_fluid
                    phase_regularization Tdot heatrelease rhocp'
        additional_outputs = 'state/cliquid state/omcliquid state/phif_l state/phif_s'
    []
    ## solid mechanics ----------------------------------------------------------
    [Jacobian]
        type = R2Determinant
        input = 'forces/F'
        determinant = 'state/J'
    []
    [M1]
        type = ScalarMultiplication
        coefficient = 1.0
        from_var = 'state/J state/rhocp'
        to_var = 'state/M1'
    []
    [fluid_F]
        type = SwellingAndPhaseChangeDeformationJacobian
        phase_fraction = 'state/cliquid'
        swelling_coefficient = '${swelling_coef}'
        reference_volume_difference = '${dOmega_f}'
        jacobian = 'state/Jf'
        fluid_fraction = 'state/phif'
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
    [model_pk1]
        type = ComposedModel
        models = 'fluid_F Jtotal phif
                  Fthermal totalF green_strain S_pk2 S_pk2_R2 S_pk1'
        additional_outputs = 'state/Fe'
    []
    [model_sm]
        type = ComposedModel
        models = 'model_pk1'
    []
    [M1pM3]
        type = ScalarLinearCombination
        from_var = 'state/M1 state/M3'
        to_var = 'state/M1pM3'
        coefficients = '1.0 1.0'
    []
    ############################################################
    [model]
        type = ComposedModel
        models = 'model_sm solidification_model Jacobian M1 M1pM3'
        additional_outputs = 'state/phif_s state/phif_l state/M1 state/M3'
    []
[]