[Solvers]
    [newton]
        type = NewtonWithLineSearch
        linesearch_type = STRONG_WOLFE
        linesearch_cutback = 1.55

        #type = Newton
        rel_tol = 1e-8
        abs_tol = 1e-10
        max_its = 100
        verbose = false
    []
[]

[Models]
    [inlet_gap]
        type = InletGap
        product_thickness_growth_ratio = '${M}'
        initial_porosity = '${phi0}'
        product_thickness = 'state/delta'
        inlet_gap = 'state/r1'
    []
    #############################################
    [product_geo]
        type = ProductSaturation
        product_molar_volume = '${oP}'
        product_span = 'state/h'
        maximum_span_condition = true
        inlet_gap = 'state/r1'
        product_thickness = 'state/delta'
        product_saturation = 'state/alphaP'
    []
    [alphamax]
        type = LiquidSaturationLimitRatio
        liquid_molar_volume = '${oL}'
        inlet_gap = 'state/r1'
        liquid_saturation = 'forces/alpha'
        limit_saturation_ratio = 'state/alphamax'
    []
    [alpha_transition]
        type = SwitchingFunction
        smoothness = '${smooth}'
        smooth_type = 'SIGMOID'
        scale = 1.0
        offset = 1.0
        complement_condition = true
        variable = 'state/alphamax'

        out = 'state/alpha_transition'
    []
    [aR_dot]
        type = ScalarVariableRate
        variable = 'state/alphaP'
        time = 'forces/tt'
        rate = 'state/aRdot'
    []
    [alpha_dot]
        type = ScalarVariableRate
        variable = 'forces/alpha'
        time = 'forces/tt'
        rate = 'state/alphadot'
    []
    [mass_balance]
        type = LIMassBalance
        in = 'state/aLInDot'
        switch = 'state/alpha_transition'
        minus_reaction = 'state/aRdot'
        stoichiometric_coefficient = '${sto_coef}'
        current = 'state/alphadot'
        total = 'residual/aLInDot'
    []
    ############### ALPHA RESIDUAL ###############
    [residual_alpha]
        type = ComposedModel
        models = 'product_geo inlet_gap alpha_transition aR_dot alpha_dot mass_balance alphamax'
    []
    #############################################
    [perfect_growth]
        type = DiffusionalProductThicknessGrowth
        liquid_product_density_ratio = '${rho_rat}'
        initial_porosity = '${phi0}'
        product_thickness_growth_ratio = '${M}'
        liquid_product_diffusion_coefficient = '${D_LP}'
        representative_pores_size = '${lc}'

        inlet_gap = 'state/r1'
        product_thickness = 'state/delta'
        ideal_thickness_growth = 'state/delta_growth'
    []
    [delta_dcrit_ratio]
        type = ProductThicknessLimitRatio
        initial_porosity = '${phi0}'
        product_thickness_growth_ratio = '${M}'
        product_thickness = 'state/delta'
        limit_ratio = 'state/dratio'
    []
    [delta_limit]
        type = SwitchingFunction
        smoothness = '${smooth}'
        smooth_type = 'SIGMOID'
        scale = 1.0
        offset = 1.0
        complement_condition = true
        variable = 'state/dratio'
        out = 'state/dlimit'
    []
    [ddot]
        type = ScalarVariableRate
        variable = 'state/delta'
        time = 'forces/tt'
        rate = 'state/ddot'
    []
    [alphalowbound]
        type = SwitchingFunction
        smoothness = '${smooth}'
        smooth_type = 'SIGMOID'
        scale = 1.0
        offset = 0.0
        complement_condition = false
        variable = 'state/alphamax'
        out = 'state/alphazero'
    []
    [product_thickness_growth]
        type = ProductThicknessGrowthRate
        thickness_rate = 'state/ddot'
        scale = 'state/alphazero'
        #scaling_condition = false
        ideal_thickness_growth = 'state/delta_growth'
        switch = 'state/dlimit'
        residual_delta = 'residual/delta'
    []
    ############### DELTA RESIDUAL ###############
    [residual_delta]
        type = ComposedModel
        models = 'inlet_gap perfect_growth delta_dcrit_ratio delta_limit ddot product_thickness_growth alphalowbound alphamax'
    []
    #############################################
    [dummy]
        type = ScalarLinearCombination
        coefficients = "1.0 -1.0"
        from_var = 'state/h old_state/h'
        to_var = 'residual/h'
    []
    [model_residual]
        type = ComposedModel
        models = 'residual_alpha residual_delta dummy'
        automatic_scaling = true
    []
    [model_update]
        type = ImplicitUpdate
        implicit_model = 'model_residual'
        solver = 'newton'
    []
    [inlet_gap_new]
        type = InletGap
        product_thickness_growth_ratio = '${M}'
        initial_porosity = '${phi0}'
        product_thickness = 'state/delta'
        inlet_gap = 'state/r1'
    []
    [aSiC_new]
        type = ProductSaturation
        product_molar_volume = '${oP}'
        product_span = 'state/h'
        maximum_span_condition = true
        inlet_gap = 'state/r1'
        product_thickness = 'state/delta'
        product_saturation = 'state/alphaP'
    []
    #[alpha_source]
    #    type = ScalarVariableRate
    #    variable = 'forces/alpha'
    #    time = 'forces/tt'
    #    rate = 'state/alpha_source'
    #[]
    [alpha_source]
        type = ScalarVariableRate
        variable = 'state/alphaP'
        time = 'forces/tt'
        rate = 'state/alpha_source'
    []
    #[alphadot_new]
    #    type = ScalarVariableRate
    #    variable = 'forces/alpha'
    #    time = 'forces/tt'
    #    rate = 'forces/alphadotn'
    #[]
    #[alpha_source]
    #    type = ScalarLinearCombination
    #    coefficients = "-1.0 1.0"
    #    from_var = 'forces/alphadotn state/aLInDot'
    #    to_var = 'state/alpha_source'
    #[]
    [alphamax_new]
        type = LiquidSaturationLimitRatio
        liquid_molar_volume = '${oL}'
        inlet_gap = 'state/r1'
        liquid_saturation = 'forces/alpha'
        limit_saturation_ratio = 'state/alphamax'
    []
    [alpha_transition_new]
        type = SwitchingFunction
        smoothness = '${smooth}'
        smooth_type = 'SIGMOID'
        scale = 0.9
        offset = 1.0
        complement_condition = false
        variable = 'state/alphamax'

        out = 'state/alpha_transition'
    []
    [diffusion_coef]
        type = EffectiveDiffusivity
        macroscopic_diffusion_coefficient = '${D_macro}'
        coefficient_liquid_limit = '${Dmulti_alphamax}'
        scaling_liquid_limit = 'state/aLInDot'
        const_liquid_limit = true
        switching_liquid_limit = 'state/alpha_transition'
        effective_diffusion_coefficient = 'state/Deff'
    []
    #[pressure]
    #    type = InfiltrationPressure
    #    initial_pressure = ${P0}
    #    alpha_alphamax_ratio = 'state/alphamax'
    #    pressure = 'state/P'
    #[]
    [pressure]
        type = ScalarLinearCombination
        coefficients = "${P0}"
        from_var = 'state/alpha_transition'
        to_var = 'state/P'
    []
    [model]
        type = ComposedModel
        models = 'model_update inlet_gap_new aSiC_new alpha_source alphamax_new alpha_transition_new diffusion_coef pressure'
        additional_outputs = 'state/delta state/h state/aLInDot state/alphaP state/alphamax'
    []
[]