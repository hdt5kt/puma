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
    ######## stress-strain relation
    [phase_strain]
        type = PhaseTransformationEigenstrain
        volume_fraction_change = '${alpha_deltaOmega}'
        phase_fraction = 'state/f_solid'
        eigenstrain = 'forces/Ept'
    []
    [elastic_strain]
        type = SR2LinearCombination
        coefficients = '1.0 -1.0'
        from_var = 'forces/eps forces/Ept'
        to_var = 'state/eps_total'
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
        models = 'SiPhase phase_strain elastic_strain stress_strain'
    []
    [model]
        type = ComposedModel
        models = 'model_kinetic ssout'
    []
[]
