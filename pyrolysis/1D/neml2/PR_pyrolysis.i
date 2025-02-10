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
    [solid_rate]
        type = ScalarVariableRate
        variable = 'state/ms'
        time = 'forces/tt'
        rate = 'state/ms_dot'
    []
    [binder_rate]
        type = ScalarVariableRate
        variable = 'state/mb'
        time = 'forces/tt'
        rate = 'state/mb_dot'
    []
    [residual_binder]
        type = ScalarLinearCombination
        coefficients = "1.0 ${Ym1}"
        from_var = 'state/mb_dot state/ms_dot'
        to_var = 'residual/mb'
    []
    [rmb]
        type = ComposedModel
        models = 'solid_rate binder_rate residual_binder'
    []
    [gas_rate]
        type = ScalarVariableRate
        variable = 'state/mg'
        time = 'forces/tt'
        rate = 'state/mg_dot'
    []
    [residual_gas]
        type = ScalarLinearCombination
        coefficients = "1.0 ${invYm1}"
        from_var = 'state/mg_dot state/ms_dot'
        to_var = 'residual/mg'
    []
    [rmg]
        type = ComposedModel
        models = 'solid_rate gas_rate residual_gas'
    []
    [rmp]
        type = ScalarLinearCombination
        coefficients = "1.0 -1.0"
        from_var = 'state/mp old_state/mp'
        to_var = 'residual/mp'
    []
    [void_volume_rate]
        type = ScalarVariableRate
        variable = 'state/Vv'
        time = 'forces/tt'
        rate = 'state/Vv_dot'
    []
    ############## currently simple model to get void fraction ##############
    [residual_Vv]
        type = ScalarLinearCombination
        coefficients = "1.0 ${rho_bm1}"
        from_var = 'state/Vv_dot state/mb_dot'
        to_var = 'residual/Vv'
    []
    [rVv]
        type = ComposedModel
        models = 'binder_rate void_volume_rate residual_Vv'
    []
    ##########################################################################
    [model_residual]
        type = ComposedModel
        models = 'rmp rms rmb rmg rVv'
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
    [amount_rate_new]
        type = ScalarVariableRate
        variable = 'state/alpha'
        time = 'forces/tt'
        rate = 'state/alpha_dot'
    []
    [model_solver]
        type = ComposedModel
        models = 'model_update amount_new amount_rate_new'
        additional_outputs = 'state/ms state/alpha'
    []
    ################################### POST PROCESS #################################
    #########
    ######### weight fraction
    [M]
        type = ScalarLinearCombination
        coefficients = "1.0 1.0 1.0"
        from_var = 'state/mp state/mb state/ms'
        to_var = 'state/M'
    []
    [wb]
        type = Ratio
        numerator = 'state/mb'
        denominator = 'state/M'
        out = 'state/wb'
    []
    [wp]
        type = Ratio
        numerator = 'state/mp'
        denominator = 'state/M'
        out = 'state/wp'
    []
    [ws]
        type = Ratio
        numerator = 'state/ms'
        denominator = 'state/M'
        out = 'state/ws'
    []
    [wout]
        type = ComposedModel
        models = 'M wb wp ws'
    []
    #########
    ######### volume fraction
    [Vb]
        type = ScalarLinearCombination
        coefficients = '${rho_bm1}'
        from_var = "state/mb"
        to_var = "state/Vb"
    []
    [Vp]
        type = ScalarLinearCombination
        coefficients = '${rho_pm1}'
        from_var = "state/mp"
        to_var = "state/Vp"
    []
    [Vs]
        type = ScalarLinearCombination
        coefficients = '${rho_sm1}'
        from_var = "state/ms"
        to_var = "state/Vs"
    []
    [V]
        type = ScalarLinearCombination
        coefficients = "1.0 1.0 1.0 1.0"
        from_var = 'state/Vp state/Vb state/Vv state/Vs'
        to_var = 'state/V'
    []
    [vb]
        type = Ratio
        numerator = 'state/Vb'
        denominator = 'state/V'
        out = 'state/vb'
    []
    [vp]
        type = Ratio
        numerator = 'state/Vp'
        denominator = 'state/V'
        out = 'state/vp'
    []
    [vs]
        type = Ratio
        numerator = 'state/Vs'
        denominator = 'state/V'
        out = 'state/vs'
    []
    [vv]
        type = Ratio
        numerator = 'state/Vv'
        denominator = 'state/V'
        out = 'state/vv'
    []
    [vout]
        type = ComposedModel
        models = 'V Vp Vb Vs vb vp vs vv'
    []
    #########
    ######### element properties
    [rho]
        type = ScalarLinearCombination
        coefficients = '${rho_p} ${rho_b} ${rho_s}'
        from_var = 'state/vp state/vb state/vs'
        to_var = 'state/rho'
    []
    [cp]
        type = ScalarLinearCombination
        coefficients = '${cp_p} ${cp_b} ${cp_s}'
        from_var = 'state/wp state/wb state/ws'
        to_var = 'state/cp'
    []
    [rhocp]
        type = Product
        variable_a = 'state/rho'
        variable_b = 'state/cp'
        out = 'state/rhocp'
    []
    [K]
        type = ScalarLinearCombination
        coefficients = '${k_p} ${k_b} ${k_s}'
        from_var = 'state/vp state/vb state/vs'
        to_var = 'state/K'
    []
    [elout]
        type = ComposedModel
        models = 'Vp Vb Vs V vp vb vs wout rho cp K rhocp'
        additional_outputs = 'state/V state/Vb state/Vs state/Vp state/rho state/cp'
    []
    [model]
        type = ComposedModel
        models = 'model_solver vout wout elout'
        additional_outputs = 'state/ms state/mp state/mg state/mb state/Vv'
    []
[]