[Models]
    [Jacobian]
        type = R2Determinant
        input = 'forces/F'
        determinant = 'state/J'
    []
    [Pressure]
        type = ScalarLinearCombination
        coefficients = "1.0 1.0"
        from_var = 'forces/T forces/P'
        to_var = 'state/pc'
    []
    [Jtotal]
        type = ThermalDeformationJacobian
        temperature = 'forces/T'
        reference_temperature = 300
        CTE = 1e-5
        jacobian = 'state/JFthermal'
    []
    [totalF]
        type = VolumeAdjustDeformationGradient
        input = 'forces/F'
        output = 'state/Fe'
        jacobian = 'state/JFthermal'
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
        coefficients = '${E} ${mu}'
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
    [model]
        type = ComposedModel
        models = 'Jacobian Jtotal totalF green_strain S_pk2 S_pk2_R2 S_pk1 Pressure'
    []
[]