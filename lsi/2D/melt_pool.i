h0 = 13.2
L0 = 0.5

[Problem]
  kernel_coverage_check = FALSE
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/pool.msh'
  []
  coord_type = RZ
[]

[Variables]
  [l]
    [InitialCondition]
      type = FunctionIC
      function = 'y-${h0}'
    []
  []
  [h]
    order = FIRST
    family = SCALAR
  []
[]

[AuxVariables]
  [M]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = M
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
[]

[ICs]
  [h0]
    type = ScalarConstantIC
    variable = h
    value = ${h0}
  []
[]

[Kernels]
  [material]
    type = LevelsetMaterialization
    variable = l
    scalar_variable = h
    volume_change_rate = volume_rate
    levelset_function = L
    levelset_function_derivative = dL/dhv
    levelset_function_second_derivative = 0
    materialization_function_derivative = dM/dL
    materialization_function_second_derivative = d^2M/dL^2
  []
[]

[Materials]
  [L]
    type = DerivativeParsedMaterial
    property_name = L
    expression = 'y-hv'
    postprocessor_names = 'hv'
    extra_symbols = 'y'
    additional_derivative_symbols = 'hv'
    derivative_order = 2
  []
  [M]
    type = DerivativeParsedMaterial
    property_name = M
    expression = 'x:=if(L<0,if(L>-${L0},-L/${L0},1),0); 3*x^2-2*x^3'
    material_property_names = 'L'
    additional_derivative_symbols = 'L'
    derivative_order = 2
  []
[]

[Postprocessors]
  [hv]
    type = ScalarVariable
    variable = h
    component = 0
    execute_on = 'INITIAL LINEAR'
    outputs = 'none'
  []
  [volume_rate]
    type = Receiver
    outputs = 'none'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  line_search = none

  nl_abs_tol = 1e-06
  nl_rel_tol = 1e-08
  nl_max_its = 12

  dt = 1e10 # limited by the master app
[]

[Outputs]
  exodus = true
  console = false
  print_linear_residuals = false
[]
