[Models]
    # [Jacobian]
    # type = DeformationGradientJacobian
    # deformation_gradient = 'forces/F'
    # jacobian = 'state/J'
    # []
    # [M1]
    #     type = ScalarLinearCombination
    #     coefficients = "${rho_f}"
    #     from_var = 'state/J'
    #     to_var = 'state/M1'
    # []
    [phif_max]
        type = ScalarParameterToState
        from = 1.0
        to = 'state/phif_max'
    []
    [permeability]
        type = PowerLawPermeability
        reference_permeability = ${kk_L}
        reference_porosity = 0.9
        power = ${permeability_power}
        porosity = 'state/phif_max'
        permeability = 'state/perm'
    []
    [M3]
        type = ScalarLinearCombination
        coefficients = "${rhof_nu}"
        from_var = 'state/perm'
        to_var = 'state/M3'
    []
    [M4]
        type = ScalarLinearCombination
        coefficients = "${rhof2_nu}"
        from_var = 'state/perm'
        to_var = 'state/M4'
    []
    [effective_saturation]
        type = EffectiveSaturation
        residual_volume_fraction = 0.0
        flow_fraction = 'forces/phif'
        max_fraction = 'state/phif_max'
        effective_saturation = 'state/Seff'
    []
    [capillary_pressure]
        type = BrooksCoreyPressure
        threshold_pressure = '${brooks_corey_threshold}'
        power = '${capillary_pressure_power}'
        effective_saturation = 'state/Seff'
        capillary_pressure = 'state/Pc'
        apply_log_extension = true
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
    [model]
        type = ComposedModel
        models = 'empty_porosity phif_max permeability effective_saturation capillary_pressure M3 M4 M5'
    []
[]