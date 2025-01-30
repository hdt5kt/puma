n = 100
L = 1
t_end = 7200
t_ramp = 600
nstep = 200

D = 1e-4
phi_SiC0 = 0
phi_C0 = 0.3

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${n}
  xmax = ${L}
[]

[Variables]
  [alpha]
  []
[]

[Kernels]
  [transient]
    type = TimeDerivative
    variable = alpha
  []
  [diffusion]
    type = MatDiffusion
    variable = alpha
    diffusivity = D
  []
[]

[NEML2]
  input = 'Si_SiC_C.i'

  [all]
    model = 'model'
    verbose = true
    device = 'cpu'

    moose_input_types = 'VARIABLE     POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL'
    moose_inputs = '     alpha        time          time          phi_SiC         phi_C'
    neml2_inputs = '     forces/alpha forces/t      old_forces/t  old_state/phi_p old_state/phi_s'

    moose_output_types = 'MATERIAL    MATERIAL    MATERIAL'
    moose_outputs = '     phi_SiC     phi_C       phi_Si'
    neml2_outputs = '     state/phi_p state/phi_s state/phi_l'

    initialize_outputs = '      phi_SiC  phi_C'
    initialize_output_values = 'phi_SiC0 phi_C0'
  []
[]

[Materials]
  [D]
    type = GenericConstantMaterial
    prop_names = 'D phi_SiC0 phi_C0'
    prop_values = '${D} ${phi_SiC0} ${phi_C0}'
  []
[]

[Functions]
  [alpha_ramp]
    type = PiecewiseLinear
    x = '0 ${t_ramp}'
    y = '0 0.05'
  []
[]

[BCs]
  [left]
    type = FunctionDirichletBC
    variable = alpha
    boundary = left
    function = 'alpha_ramp'
  []
[]

[Postprocessors]
  [time]
    type = TimePostprocessor
    execute_on = 'INITIAL TIMESTEP_BEGIN'
    outputs = 'csv'
  []
[]

[AuxVariables]
  [phi_SiC]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phi_SiC
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_Si]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phi_Si
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_C]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phi_C
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_0]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ParsedAux
      expression = '1-phi_SiC-phi_C-phi_Si'
      material_properties = 'phi_SiC phi_C phi_Si'
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
[]

[VectorPostprocessors]
  [value]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${L} 0 0'
    num_points = ${n}
    variable = 'alpha phi_Si phi_SiC phi_C phi_0'
    sort_by = 'x'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  solve_type = 'newton'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  line_search = none

  nl_abs_tol = 1e-06
  nl_rel_tol = 1e-08
  nl_max_its = 12

  end_time = ${t_end}
  dt = '${fparse t_end/nstep}'
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = 'results/out'
  []
  print_linear_residuals = false
[]
