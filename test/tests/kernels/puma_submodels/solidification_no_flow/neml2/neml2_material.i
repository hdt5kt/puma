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
        models = 'phif Tdot0 Jacobian liquid_phase_portion solid_phase_portion liquid_phase_fluid solid_phase_fluid
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
        type = PhaseChangeDeformationGradientJacobian
        phase_fraction = 'state/cliquid'
        CPE = '${swelling_coef}'
        CPC = '${dOmega_f}'
        jacobian = 'state/Jf'
        fluid_fraction = 'state/phif'
    []
    # thermal add-on ###########
    [Fthermal]
        type = ThermalDeformationGradientJacobian
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
        models = 'fluid_F Jtotal phif
                  Fthermal totalF green_strain S_pk2 S_pk2_R2 S_pk1'
        additional_outputs = 'state/Fe'
    []
    [model_sm]
        type = ComposedModel
        models = 'Jacobian M1 model_pk1'
    []
    ############################################################
    [model]
        type = ComposedModel
        models = 'model_sm model_solidification'
        additional_outputs = 'state/phif_s state/phif_l'
    []
[]