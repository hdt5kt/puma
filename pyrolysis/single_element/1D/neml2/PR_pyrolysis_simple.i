[Solvers]
    [newton]
        #type = NewtonWithLineSearch
        #linesearch_type = STRONG_WOLFE
        #linesearch_cutback = 1.55

        type = Newton
        rel_tol = 1e-8
        abs_tol = 1e-10
        max_its = 100
        verbose = false
    []
[]

[Models]
    [amount]
        type = PyrolysisConversionAmount
        initial_mass_solid = '${ms0}'
        initial_mass_binder = '${mb0}'
        reaction_yield = '${Y}'

        mass_solid = 'state/ms'
        reaction_amount = 'state/alpha'
    []
    [reaction]
        type = ChemicalReactionModel
        scaling_constant = '${order_k}'
        reaction_order = '${order}'
        reaction_amount = 'state/alpha'
        reaction_out = 'state/f'
    []
    [pyrolysis]
        type = PyrolysisKinetics
        kinetic_constant = '${A}'
        activation_energy = '${Ea}'
        ideal_gas_constant = '${R}'
        temperature = 'forces/T'
        reaction = 'state/f'
        out = 'state/pyro'
    []
    [amount_rate]
        type = ScalarVariableRate
        variable = 'state/alpha'
        time = 'forces/tt'
        rate = 'state/alpha_dot'
    []
    [residual_ms]
        type = ScalarLinearCombination
        coefficients = "1.0 -1.0"
        from_var = 'state/alpha_dot state/pyro'
        to_var = 'residual/ms'
    []
    [rms]
        type = ComposedModel
        models = 'amount reaction pyrolysis amount_rate residual_ms'
    []
    [model_residual]
        type = ComposedModel
        models = 'rms'
        automatic_scaling = true
    []
    [model_update]
        type = ImplicitUpdate
        implicit_model = 'model_residual'
        solver = 'newton'
    []
    [amount_new]
        type = PyrolysisConversionAmount
        initial_mass_solid = '${ms0}'
        initial_mass_binder = '${mb0}'
        reaction_yield = '${Y}'

        mass_solid = 'state/ms'
        reaction_amount = 'state/alpha'
    []
    [model]
        type = ComposedModel
        models = 'model_update amount_new'
        additional_outputs = 'state/ms'
    []

[]