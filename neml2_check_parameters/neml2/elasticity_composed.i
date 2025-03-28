[Models]
    [elastic_strain]
        type = SR2LinearCombination
        coefficients = '5.0'
        from_var = 'forces/eps'
        to_var = 'state/eps_total'
    []
    [stress_strain]
        type = LinearIsotropicElasticity
        strain = 'state/eps_total'
        stress = 'state/sigma'
        coefficients = '1000 0.31'
        coefficient_types = 'YOUNGS_MODULUS POISSONS_RATIO'
    []
    [model]
        type = ComposedModel
        models = 'elastic_strain stress_strain'
    []
    #[model]
    #    type = LinearIsotropicElasticity
    #    coefficients = '1 0.3'
    #    coefficient_types = 'YOUNGS_MODULUS POISSONS_RATIO'
    #    strain = 'forces/E'
    #[]
[]