[Solvers]
    [newton]
        type = Newton
        #rel_tol = 1e-8
        #abs_tol = 1e-10
        #max_its = 100
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
    [model_kinetic]
        type = ComposedModel
        models = 'SiPhase qnorm q qdot'
        additional_outputs = 'state/f_solid state/q'
    []
    ### set the amount of substance to be conserved
    [alpha_rate]
        type = ScalarVariableRate
        variable = 'state/alpha'
        rate = 'residual/alpha'
        time = 'forces/t'
    []
    [phi_P_rate]
        type = ScalarVariableRate
        variable = 'state/phi_P'
        rate = 'residual/phi_P'
        time = 'forces/t'
    []
    [phi_S_rate]
        type = ScalarVariableRate
        variable = 'state/phi_S'
        rate = 'residual/phi_S'
        time = 'forces/t'
    []
    [imp_model]
        type = ComposedModel
        models = 'alpha_rate phi_S_rate phi_P_rate'
    []
    [substance_update]
        type = ImplicitUpdate
        implicit_model = 'imp_model'
        solver = 'newton'
    []
    ######## global properties
    [phi_L_new]
        type = ScalarLinearCombination
        from_var = 'state/alpha'
        to_var = 'state/phi_L'
        coefficients = '${omega_L}'
    []
    [rho]
        type = ScalarLinearCombination
        coefficients = '${rho_L} ${rho_P} ${rho_S}'
        from_var = 'state/phi_L state/phi_P state/phi_S'
        to_var = 'state/rho'
    []
    [cp]
        type = ScalarLinearCombination
        coefficients = '${cp_L} ${cp_P} ${cp_S}'
        from_var = 'state/phi_L state/phi_P state/phi_S'
        to_var = 'state/cp'
    []
    [rhocp]
        type = Product
        variable_a = 'state/rho'
        variable_b = 'state/cp'
        out = 'state/rhocp'
    []
    [elout]
        type = ComposedModel
        models = 'substance_update phi_L_new rho cp rhocp'
    []
    ######## stress-strain relation
    [thermal_strain]
        type = ThermalEigenstrain
        reference_temperature = '${Tref}'
        temperature = 'forces/T'
        CTE = '${g}'
        eigenstrain = 'forces/Et'
    []
    [init_alpha]
        type = ScalarLinearCombination
        from_var = 'state/alpha'
        to_var = 'state/alpha_deltaOmega'
        coefficients = '${deltaOmega}'
    []
    [phase_strain]
        type = PhaseTransformationEigenstrain
        volume_fraction_change = 'state/alpha_deltaOmega' # '${alpha_deltaOmega}'
        phase_fraction = 'state/f_solid'
        eigenstrain = 'forces/Ept'
    []
    [elastic_strain]
        type = SR2LinearCombination
        coefficients = '1.0 -1.0 -1.0'
        from_var = 'forces/eps forces/Ept forces/Et'
        to_var = 'state/eps_total'
    []
    [thermal_stress]
        type = LinearIsotropicElasticity
        strain = 'forces/Et'
        stress = 'state/s_thermal'
        coefficients = '${E} ${mu}'
        coefficient_types = 'YOUNGS_MODULUS POISSONS_RATIO'
    []
    [phase_stress]
        type = LinearIsotropicElasticity
        strain = 'forces/Ept'
        stress = 'state/s_phase'
        coefficients = '${E} ${mu}'
        coefficient_types = 'YOUNGS_MODULUS POISSONS_RATIO'
    []
    [stress_strain]
        type = LinearIsotropicElasticity
        strain = 'state/eps_total'
        stress = 'state/sigma'
        coefficients = '${E} ${mu}'
        coefficient_types = 'YOUNGS_MODULUS POISSONS_RATIO'
    []
    [ssout]
        type = ComposedModel
        models = 'init_alpha SiPhase phase_strain phase_stress elastic_strain
                  thermal_strain thermal_stress stress_strain'
    []
    [model]
        type = ComposedModel
        models = 'model_kinetic ssout substance_update elout'
        additional_outputs = 'state/alpha state/phi_P state/phi_S'
    []
[]
