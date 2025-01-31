D = 1e-4
omega_Si = 12
omega_C = 5.3
omega_SiC = 12.5
omega_r = 0.424 # omega_Si/Omega_SiC

[Solvers]
  [newton]
    type = Newton
  []
[]

[Models]
  [liquid_fraction]
    type = ScalarLinearCombination
    from_var = 'forces/alpha'
    to_var = 'state/phi_l'
    coefficients = '${omega_Si}'
  []
  [liquid_reactivity]
    type = HermiteSmoothStep
    argument = 'state/phi_l'
    value = 'state/R_l'
    lower_bound = 0
    upper_bound = 0.1
  []
  [solid_reactivity]
    type = HermiteSmoothStep
    argument = 'state/phi_s'
    value = 'state/R_s'
    lower_bound = 0
    upper_bound = 0.1
  []
  [product_geometry]
    type = ProductGeometry
  []
  [diffusion]
    type = DiffusionLimitedReaction
    diffusion_coefficient = ${D}
    molar_volume = ${omega_Si}
  []
  [reaction]
    type = ComposedModel
    models = 'liquid_reactivity solid_reactivity product_geometry diffusion'
  []
  [product_rate]
    type = ScalarLinearCombination
    from_var = 'state/alpha_rate'
    to_var = 'state/phi_p_rate'
    coefficients = '${omega_SiC}'
  []
  [solid_rate]
    type = ScalarLinearCombination
    from_var = 'state/alpha_rate'
    to_var = 'state/phi_s_rate'
    coefficients = '-${omega_Si}'
  []
  [integrate_phi_p]
    type = ScalarBackwardEulerTimeIntegration
    variable = 'state/phi_p'
  []
  [integrate_phi_s]
    type = ScalarBackwardEulerTimeIntegration
    variable = 'state/phi_s'
  []
  [system]
    type = ComposedModel
    models = "liquid_fraction reaction
              product_rate solid_rate
              integrate_phi_p integrate_phi_s"
  []
  [model0]
    type = ImplicitUpdate
    implicit_model = 'system'
    solver = 'newton'
  []
  [model]
    type = ComposedModel
    models = 'model0 liquid_fraction reaction'
    additional_outputs = 'state/phi_p state/phi_s state/phi_l'
  []
[]
