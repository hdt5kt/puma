[Solvers]
    [newton]
        type = Newton
        verbose = false
    []
[]

[Models]
    [outer_radius]
        type = CylindricalChannelGeometry
        solid_fraction = 'state/phi_S'
        product_fraction = 'state/phi_P'
        inner_radius = 'state/ri'
        outer_radius = 'state/ro'
    []
    [liquid_reactivity]
        type = HermiteSmoothStep
        argument = 'forces/phi_L'
        value = 'state/R_L'
        lower_bound = 0
        upper_bound = 0.1
    []
    [solid_reactivity]
        type = HermiteSmoothStep
        argument = 'state/phi_S'
        value = 'state/R_S'
        lower_bound = 0
        upper_bound = 0.1
    []
    [reaction_rate]
        type = DiffusionLimitedReaction
        diffusion_coefficient = '${D}'
        molar_volume = '${omega_Si}'
        product_inner_radius = 'state/ri'
        solid_inner_radius = 'state/ro'
        liquid_reactivity = 'state/R_L'
        solid_reactivity = 'state/R_S'
        reaction_rate = 'state/react'
    []
    [substance_product]
        type = ScalarLinearCombination
        from_var = 'state/phi_P'
        to_var = 'state/alpha_P'
        coefficients = '${oSiCm1}'
    []
    [product_rate]
        type = ScalarVariableRate
        variable = 'state/alpha_P'
        rate = 'state/adot_P'
        time = 'forces/t'
    []
    [substance_solid]
        type = ScalarLinearCombination
        from_var = 'state/phi_S'
        to_var = 'state/alpha_S'
        coefficients = '${oCm1}'
    []
    [solid_rate]
        type = ScalarVariableRate
        variable = 'state/alpha_S'
        rate = 'state/adot_S'
        time = 'forces/t'
    []
    ##############################################
    ### IVP
    ##############################################
    [residual_phiP]
        type = ScalarLinearCombination
        from_var = 'state/adot_P state/react'
        to_var = 'residual/phi_P'
        coefficients = '1.0 -1.0'
    []
    [residual_phiS]
        type = ScalarLinearCombination
        from_var = 'state/adot_P state/adot_S'
        to_var = 'residual/phi_S'
        coefficients = '1.0 ${chem_ratio}'
    []
    [model_residual]
        type = ComposedModel
        models = "residual_phiP residual_phiS
                outer_radius liquid_reactivity solid_reactivity
                  reaction_rate substance_product product_rate substance_solid  solid_rate"
    []
    [model_update]
        type = ImplicitUpdate
        implicit_model = 'model_residual'
        solver = 'newton'
    []
    [substance_product_new]
        type = ScalarLinearCombination
        from_var = 'state/phi_P'
        to_var = 'state/alpha_P'
        coefficients = '${oSiCm1}'
    []
    [substance_solid_new]
        type = ScalarLinearCombination
        from_var = 'state/phi_S'
        to_var = 'state/alpha_S'
        coefficients = '${oCm1}'
    []
    [model_solver]
        type = ComposedModel
        models = 'model_update substance_solid_new substance_product_new'
        additional_outputs = 'state/phi_P state/phi_S'
    []
    ##############################################
    ### Post-process
    ##############################################

    # reaction rate for liquid
    [outer_radius_new]
        type = CylindricalChannelGeometry
        solid_fraction = 'state/phi_S'
        product_fraction = 'state/phi_P'
        inner_radius = 'state/ri'
        outer_radius = 'state/ro'
    []
    [reaction_rate_new]
        type = DiffusionLimitedReaction
        diffusion_coefficient = '${D}'
        molar_volume = '${omega_Si}'
        product_inner_radius = 'state/ri'
        solid_inner_radius = 'state/ro'
        liquid_reactivity = 'state/R_L'
        solid_reactivity = 'state/R_S'
        reaction_rate = 'state/react'
    []
    [alpha_rate]
        type = ScalarLinearCombination
        from_var = 'state/react'
        to_var = 'state/alpha_dot'
        coefficients = '${chem_P}'
    []
    [liquid_consumption_rate]
        type = ScalarLinearCombination
        from_var = 'state/alpha_dot'
        to_var = 'state/phidot_L'
    []
    [void]
        type = ScalarLinearCombination
        from_var = 'state/phi_P state/phi_S forces/phi_L'
        to_var = 'state/vf'
        coefficients = '-1.0 -1.0 -1.0'
        constant_coefficient = 1.0
    []
    [consumption]
        type = ComposedModel
        models = 'liquid_reactivity solid_reactivity void outer_radius_new reaction_rate_new alpha_rate liquid_consumption_rate'
        additional_outputs = 'state/ri'
    []
    # capillary pressure
    [phimax_L]
        type = ScalarLinearCombination
        from_var = 'state/phi_P state/phi_S'
        to_var = 'state/phimax_L'
        coefficients = '-1.0 -1.0'
        constant_coefficient = 1.0
    []
    [effective_saturation]
        type = EffectiveSaturation
        residual_saturation = ${phi_L_residual}
        fluid_fraction = 'forces/phi_L'
        max_fraction = 'phimax_L'
        effective_saturation = 'state/Seff'
    []
    [capillary_pressure]
        type = VanGenuchtenCapillaryPressure
        effective_saturation = 'state/Seff'
        a = 4.5e-4
        m = 0.5
        capillary_pressure = 'state/P'
        log_extension = true
        transition_saturation = 0.1
    []
    [pore_pressure]
        type = ScalarLinearCombination
        from_var = 'state/P'
        to_var = 'state/Pc'
        coefficients = '-1.0'
    []
    [Pc]
        type = ComposedModel
        models = ' effective_saturation pore_pressure capillary_pressure'
        additional_outputs = 'state/phimax_L state/Seff'
    []
    [model_out]
        type = ComposedModel
        models = 'model_solver Pc'
        additional_outputs = 'state/phi_P state/phi_S'
    []
    [dPcdphiL]
        type = Normality
        model = model_out
        function = 'state/Pc'
        from = 'forces/phi_L'
        to = 'state/dPcdphiL'
    []
    [model]
        type = ComposedModel
        models = 'model_out dPcdphiL consumption'
        additional_outputs = 'state/phi_P state/phi_S'
    []
[]
