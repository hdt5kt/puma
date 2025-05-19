[Mesh]
  type = GeneratedMesh
  dim = 1
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
    type = PumaCoupledTimeDerivative
    material_prop = 6
    variable = T
    temperature = T
    pressure = P
    material_temperature_derivative = 0
    material_pressure_derivative = 0
  []
  [Pvar]
    type = CoupledL2Projection
    material_prop = M
    variable = P
    temperature = T
    pressure = P
    material_temperature_derivative = dM_dT
    material_pressure_derivative = dM_dP
  []
  [Tsource]
    type = MaterialSource
    prop = 3
    prop_derivative = 0
    variable = T
  []
[]

[ICs]
  [ic_T]
    type = ConstantIC
    value = 3
    variable = T
  []
[]

[Materials]
  [M]
    type = ParsedMaterial
    property_name = M
    coupled_variables = 'T P'
    expression = 'T^2*P+P^2*T^3'
  []
  [dM_dT]
    type = ParsedMaterial
    property_name = dM_dT
    coupled_variables = 'T P'
    expression = '2*T*P+3*T^2*P^2'
  []
  [dM_dP]
    type = ParsedMaterial
    property_name = dM_dP
    coupled_variables = 'T P'
    expression = 'T^2+2*P*T^3'
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
