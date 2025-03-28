[Solvers]
    [newton]
        type = Newton
        verbose = false
    []
[]

[Models]
    [SiPhase]
        type = HermiteSmoothStep
        argument = 'forces/T'
        value = 'state/f_solid'
        lower_bound = '${Ts_low}'
        upper_bound = '${Ts_high}'
        complement_condition = true
    []
    [qnorm]
        type = HermiteSmoothStep
        argument = 'state/f_solid'
        value = 'state/qnorm'
        lower_bound = 0.0
        upper_bound = 1.0
        complement_condition = false
    []
    [q]
        type = ScalarLinearCombination
        from_var = 'state/qnorm'
        to_var = 'state/q'
        coefficients = '${H_latent}'
    []
    [qdot]
        type = ScalarVariableRate
        variable = 'state/q'
        rate = 'state/qdot'
        time = 'forces/t'
    []
    [model]
        type = ComposedModel
        models = 'SiPhase qnorm q qdot'
        additional_outputs = 'state/f_solid state/q'
    []
[]
