[Models]
    ## solid mechanics ----------------------------------------------------------
    [Jacobian]
        type = DeformationGradientJacobian
        deformation_gradient = 'forces/F'
        jacobian = 'state/J'
    []
    [cliquid]
        type = ScalarParameterToState
        from = 0.0
        to = 'state/cliquid'
    []
    [phif]
        type = ScalarParameterToState
        from = 0.0
        to = 'state/phif'
    []
    [fluid_F]
        type = PhaseChangeDeformationGradientJacobian
        phase_fraction = 'state/cliquid'
        CPE = 0.0
        CPC = '${dOmega_f}'
        jacobian = 'state/Jf'
        fluid_fraction = 'state/phif'
    []
    # thermal add-on ###########
    [Fthermal]
        type = ThermalDeformationGradientJacobian
        temperature = 'forces/T'
        reference_temperature = '${Tref}'
        CTE = 0.1
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
        coefficients = '0.1 ${nu}'
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
        models = 'fluid_F FFf cliquid phif
                  Fthermal totalF green_strain S_pk2 S_pk2_R2 S_pk1'
        additional_outputs = 'state/Fe'
    []
    [model_sm]
        type = ComposedModel
        models = 'model_pk1'
    []
    ## additional info ----------------------------------------------------------
    [phip]
        type = ScalarParameterToState
        from = 0.99
        to = 'state/phip'
    []
    [rhocp_eff]
        type = ScalarLinearCombination
        from_var = 'state/phip state/phif'
        to_var = 'state/rhocp_eff'
        coefficients = '${rhocp_SiC} ${rhocp_Si}'
    []
    [M1]
        type = ScalarMultiplication
        from_var = 'state/J state/rhocp_eff'
        to_var = 'state/M1'
    []
    [model_M1]
        type = ComposedModel
        models = 'Jacobian rhocp_eff M1 phip phif'
    []
    ############################################################
    [model]
        type = ComposedModel
        models = 'model_sm model_M1'
    []
[]