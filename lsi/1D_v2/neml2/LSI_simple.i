## Input

# parameters
M = 0.576
lc = 1.25
p = 1.0
phi0 = 0.5

# Material/system properties
oP = 1.25e-5
oL = 1.2e-5
rho_rat = 0.8
D_LP = 5e-7
sto_coef = 1.0
smooth = 100

nbatch = '(1)'

## MAIN

[Tensors]
    [M]
        type = Scalar
        values = ${M}
        batch_shape = '${nbatch}'
    []
    [phi0]
        type = Scalar
        values = ${phi0}
        batch_shape = '${nbatch}'
    []
    [p]
        type = Scalar
        values = ${p}
        batch_shape = '${nbatch}'
    []
    [lc]
        type = Scalar
        values = ${lc}
        batch_shape = '${nbatch}'
    []
[]

[Solvers]
    [newton]
        type = NewtonWithLineSearch
        linesearch_type = STRONG_WOLFE
        rel_tol = 1e-8
        abs_tol = 1e-10
        max_its = 100
        verbose = false
    []
[]

[Models]
    [inlet_gap]
        type = InletGap
        product_thickness_growth_ratio = 'M'
        initial_porosity = 'phi0'
        product_thickness = 'state/delta'
        inlet_gap = 'state/r1'
    []
    [hdot]
        type = ScalarVariableRate
        variable = 'state/h'
        time = 'forces/tt'
        rate = 'state/hdot'
    []
    [hL]
        type = LiquidSpan
        liquid_molar_volume = ${oL}
        inlet_gap = 'state/r1'
        liquid_saturation = 'forces/alpha'
        liquid_span = 'state/hL'
    []
    [pcond]
        type = ScalarLinearCombination
        coefficients = "1.0 -1.0"
        from_var = 'state/h state/hL'
        to_var = 'state/pcond'
    []
    [fbcond]
        type = FischerBurmeister
        condition_a = 'state/pcond'
        condition_b = 'state/hdot'
        fischer_burmeister = 'residual/h'
    []
    ############### H RESIDUAL ###############
    [residual_h]
        type = ComposedModel
        models = 'fbcond inlet_gap hL pcond hdot'
    []
    #############################################
    [deficient_scale]
        type = PowerLawLiquidDeficiency
        product_span = 'state/h'
        liquid_span = 'state/hL'
        exponent = 'p'
        scale = 'state/def_scale'
    []
    [perfect_growth]
        type = DiffusionalProductThicknessGrowth
        liquid_product_density_ratio = ${rho_rat}
        initial_porosity = 'phi0'
        product_thickness_growth_ratio = 'M'
        liquid_product_diffusion_coefficient = ${D_LP}
        representative_pores_size = 'lc'

        inlet_gap = 'state/r1'
        product_thickness = 'state/delta'
        ideal_thickness_growth = 'state/delta_growth'
    []
    [delta_dcrit_ratio]
        type = ProductThicknessLimitRatio
        initial_porosity = 'phi0'
        product_thickness_growth_ratio = 'M'
        product_thickness = 'state/delta'
        limit_ratio = 'state/dratio'
    []
    [delta_limit]
        type = SwitchingFunction
        smoothness = ${smooth}
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
    [product_thickness_growth]
        type = ProductThicknessGrowthRate
        thickness_rate = 'state/ddot'
        scale = 'state/def_scale'
        ideal_thickness_growth = 'state/delta_growth'
        switch = 'state/dlimit'
        residual_delta = 'residual/delta'
    []
    ############### DELTA RESIDUAL ###############
    [residual_delta]
        type = ComposedModel
        models = 'deficient_scale inlet_gap perfect_growth delta_dcrit_ratio delta_limit ddot product_thickness_growth hL'
    []
    #############################################
    [model_residual]
        type = ComposedModel
        models = 'residual_h residual_delta'
        automatic_scaling = true
    []
    [model_update]
        type = ImplicitUpdate
        implicit_model = 'model_residual'
        solver = 'newton'
    []
    [aSiC_new]
        type = ProductSaturation
        product_molar_volume = ${oP}
        product_span = 'state/h'
        inlet_gap = 'state/r1'
        product_thickness = 'state/delta'
        product_saturation = 'state/alphaP'
    []
    [alpha_source]
        type = ScalarVariableRate
        variable = 'forces/alpha'
        time = 'forces/tt'
        rate = 'state/alpha_source'
    []
    [model]
        type = ComposedModel
        models = 'model_update inlet_gap aSiC_new alpha_source'
        additional_outputs = 'state/delta state/h'
    []
[]