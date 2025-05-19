[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
[]

[Variables]
  [T]
  []
  [P]
  []
[]

[Kernels]
  [Tvar]
    type = CoupledAdditiveFlux
    value = '0.0 -9.8 0.0'
    material_prop = M
    variable = T
    temperature = T
    pressure = P
    material_temperature_derivative = dM_dT
    material_pressure_derivative = dM_dP
  []
  [Tdot]
    type = TimeDerivative
    variable = T
  []
  [Pdot]
    type = TimeDerivative
    variable = P
  []
  [Pdiffuse]
    type = Diffusion
    variable = P
  []
[]

[ICs]
  [ic_T]
    type = ConstantIC
    value = 3
    variable = T
  []
  [ic_P]
    type = ConstantIC
    value = 2
    variable = P
  []
[]

[Materials]
  [M]
    type = ParsedMaterial
    property_name = M
    coupled_variables = 'P T'
    expression = 'P^2+P^3+T'
  []
  [dM_dP]
    type = ParsedMaterial
    property_name = dM_dP
    coupled_variables = 'P'
    expression = '2*P+3*P^2'
  []
  [dM_dT]
    type = ParsedMaterial
    property_name = dM_dT
    coupled_variables = 'T P'
    expression = '1.0'
  []
[]

[BCs]
[]

[Executioner]
  type = Transient
  solve_type = 'newton'
  # petsc_options_iname = '-pc_type' #-snes_type'
  # petsc_options_value = 'lu' # vinewtonrsls'
  automatic_scaling = true

  line_search = none

  nl_abs_tol = 1e-6
  nl_rel_tol = 1e-8
  nl_max_its = 20

  dt = 1
  end_time = 1
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]
