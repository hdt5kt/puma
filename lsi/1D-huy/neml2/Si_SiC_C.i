[Solvers]
    [newton]
        type = Newton
        verbose = false
    []
[]

[Models]
    [liquid_volume_fraction]
        type = ScalarLinearCombination
        from_var = 'forces/alpha'
        to_var = 'state/phi_L'
        coefficients = '${omega_Si}'
    []
    [outer_radius]
        type = ProductGeometry
        solid_fraction = 'state/phi_S'
        product_fraction = 'state/phi_P'
        inner_radius = 'state/ri'
        outer_radius = 'state/ro'
    []
    [liquid_reactivity]
        type = HermiteSmoothStep
        argument = 'state/phi_L'
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
    [residual_phiL]
        type = ScalarLinearCombination
        from_var = 'state/adot_P state/adot_S'
        to_var = 'residual/phi_S'
        coefficients = '1.0 ${chem_ratio}'
    []
    [model_residual]
        type = ComposedModel
        models = "residual_phiP residual_phiL
                  liquid_volume_fraction outer_radius liquid_reactivity solid_reactivity
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
    [alpha_rate]
        type = ScalarLinearCombination
        from_var = 'state/react'
        to_var = 'state/alpha_dot'
        coefficients = '${chem_P}'
    []
    [model]
        type = ComposedModel
        models = 'outer_radius liquid_reactivity solid_reactivity reaction_rate alpha_rate model_update liquid_volume_fraction substance_solid_new substance_product_new'
        additional_outputs = 'state/phi_P state/phi_S state/phi_L'
    []
[]
