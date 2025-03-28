[Models]
    [model]
        type = LinearIsotropicElasticity
        strain = 'forces/eps'
        stress = 'state/sigma'
        coefficients = '1 0.3'
        coefficient_types = 'YOUNGS_MODULUS POISSONS_RATIO'
    []
[]