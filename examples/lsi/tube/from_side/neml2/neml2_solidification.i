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
    [M10]
        type = ScalarMultiplication
        from_var = 'state/eta state/J'
        to_var = 'state/M10'
        coefficient = '${rhofL}'
    []
    [model_solidification]
        type = ComposedModel
        models = 'Jacobian liquid_phase_portion solid_phase_portion
                    liquid_phase_fluid solid_phase_fluid
                    phase_regularization M10'
        additional_outputs = 'state/cliquid state/omcliquid'
    []
    ## solid mechanics ----------------------------------------------------------
    [Jacobian]
        type = R2Determinant
        input = 'forces/F'
        determinant = 'state/J'
    []
    [M1]
        type = ScalarMultiplication
        coefficient = "${rho_f}"
        from_var = 'state/J state/cliquid'
        to_var = 'state/M1'
    []
    ########
    # solidification add-on ###########
    ########
    [fluid_F]
        type = SwellingAndPhaseChangeDeformationJacobian
        phase_fraction = 'state/cliquid'
        swelling_coefficient = '${swelling_coef}'
        reference_volume_difference = '${dOmega_f}'
        jacobian = 'state/Jf'
        fluid_fraction = 'forces/phif'
    []
    # thermal add-on ###########
    [Fthermal]
        type = ThermalDeformationJacobian
        temperature = 'forces/T'
        reference_temperature = '${Tref}'
        CTE = ${therm_expansion}
        jacobian = 'state/Jt'
    []
    # --------------------------------------
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
        models = 'fluid_F FFf
                  Fthermal totalF green_strain S_pk2 S_pk2_R2 S_pk1'
        additional_outputs = 'state/Fe'
    []
    [model_sm]
        type = ComposedModel
        models = 'Jacobian M1 model_pk1'
    []
    ## previous information
    [phis]
        type = ScalarParameterToState
        from = 1.0
        to = 'state/phis'
    []
    [phip]
        type = ScalarParameterToState
        from = 1.0
        to = 'state/phip'
    []
    [phinoreact]
        type = ScalarParameterToState
        from = 1.0
        to = 'state/phinoreact'
    []
    [rhocp_eff]
        type = ScalarLinearCombination
        from_var = 'state/phis state/phip forces/phif state/phinoreact'
        to_var = 'state/rhocp_eff'
        coefficients = '${rhocp_C} ${rhocp_SiC} ${rhocp_Si} ${rhocp_SiC}'
    []
    [M6]
        type = ScalarMultiplication
        from_var = 'state/J state/rhocp_eff'
        to_var = 'state/M6'
    []
    [model_M6]
        type = ComposedModel
        models = 'Jacobian rhocp_eff phis phip phinoreact M6'
    []
    ############################################################
    [model]
        type = ComposedModel
        models = 'model_sm model_solidification model_M6'
        additional_outputs = 'state/phif_s state/phif_l state/omcliquid'
    []
[]