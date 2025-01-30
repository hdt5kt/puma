D = 1e-5
omega_Si = 12
omega_C = 5.3

[Solvers]
  [newton]
    type = Newton
  []
[]

[Models]
  [liquid_fraction]
    type = LiquidFraction
    liquid_molar_volume = ${omega_Si}
    solid_molar_volume = ${omega_C}
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
  [reaction]
    type = DiffusionLimitedReaction
    diffusion_coefficient = ${D}
    liquid_molar_volume = ${omega_Si}
    solid_molar_volume = ${omega_C}
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
    models = "liquid_fraction liquid_reactivity solid_reactivity
              product_geometry reaction
              integrate_phi_p integrate_phi_s"
  []
  [model0]
    type = ImplicitUpdate
    implicit_model = 'system'
    solver = 'newton'
  []
  [model]
    type = ComposedModel
    models = 'model0 liquid_fraction'
    additional_outputs = 'state/phi_p'
  []
[]
