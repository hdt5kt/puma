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
    type = PumaCoupledDiffusion
    material_prop = M
    variable = T
    temperature = T
    pressure = P
    material_temperature_derivative = dM_dT
    material_pressure_derivative = dM_dP
  []
  [Tdot]
    type = PumaCoupledTimeDerivative
    material_prop = 1
    variable = T
    temperature = T
    material_temperature_derivative = 0.0
  []
  [Pdot]
    type = PumaCoupledTimeDerivative
    material_prop = 2.0
    variable = P
    temperature = T
    pressure = P
    material_temperature_derivative = 0.0
    material_pressure_derivative = 0.0
  []
[]

[ICs]
  [Pinit]
    type = ConstantIC
    value = 3.0
    variable = P
  []
[]

[Materials]
  [M]
    type = ParsedMaterial
    property_name = M
    coupled_variables = 'T P'
    expression = 'T^2*P^2+T^3*P'
  []
  [dM_dT]
    type = ParsedMaterial
    property_name = dM_dT
    coupled_variables = 'T P'
    expression = '2*T*P^2+3*T^2*P'
  []
  [dM_dP]
    type = ParsedMaterial
    property_name = dM_dP
    coupled_variables = 'T P'
    expression = '2*P*T^2+T^3'
  []
[]

[BCs]
  [left_fix_T]
    type = NeumannBC
    boundary = left
    value = 0.001
    variable = T
  []
[]

[Executioner]
  type = Transient
  solve_type = 'newton'
  petsc_options_iname = '-pc_type' #-snes_type'
  petsc_options_value = 'lu' # vinewtonrsls'
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
