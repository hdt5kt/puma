[Models]
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
        residual_saturation = 0.00001
        fluid_fraction = 'forces/phif'
        max_fraction = 'state/phif_max'
        effective_saturation = 'state/Seff'
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
        from_var = 'state/Pc'
        to_var = 'state/M5'
        coefficients = '-1.0'
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
    [model]
        type = ComposedModel
        models = 'solid_fraction empty_porosity phif_max permeability effective_saturation capillary_pressure M3 M4 M5'
        additional_outputs = 'state/perm'
    []
[]