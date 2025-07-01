[Solvers]
    [newton]
        type = Newton
        verbose = false
    []
[]

[Models]
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
    [cL]
        type = ScalarMultiplication
        from_var = 'state/eta'
        to_var = 'state/cL'
        coefficient = '${H_latent}'
    []
    [ceff]
        type = ScalarLinearCombination
        from_var = 'state/cL'
        to_var = 'state/ceff'
        coefficients = '${o_cp_Si}'
        constant_coefficient = 1.0
    []
    [heatrelease]
        type = ScalarMultiplication
        from_var = 'state/eta state/Tdot'
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
    [M1]
        type = ScalarLinearCombination
        from_var = 'state/phif_l state/phif_s'
        to_var = 'state/M1'
        coefficients = '${cp_rho_Si} ${cp_rho_Si_s}'
    []
    [model]
        type = ComposedModel
        models = 'phif liquid_phase_portion solid_phase_portion
                    liquid_phase_fluid solid_phase_fluid
                    phase_regularization Tdot heatrelease M1'
        additional_outputs = 'state/omcliquid state/phif_l state/phif_s'
    []
[]