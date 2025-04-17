t_end = 1200
t_ramp = 10
dt0 = 1

phi_p0 = 0
phi_s0 = 0.6
flux = 1.5e-3
D = 0.03
omega_Si = 12

[MultiApps]
  [melt_pool]
    type = TransientMultiApp
    input_files = 'melt_pool.i'
    catch_up = true
    execute_on = 'TIMESTEP_BEGIN'
  []
[]

[Transfers]
  [volume_rate]
    type = MultiAppPostprocessorTransfer
    to_multi_app = 'melt_pool'
    from_postprocessor = 'volume_rate'
    to_postprocessor = 'volume_rate'
  []
  [M]
    type = MultiAppGeneralFieldNearestLocationTransfer
    from_multi_app = 'melt_pool'
    source_type = 'centroids'
    source_variable = 'M'
    variable = 'M'
    to_boundaries = 'inlet'
    error_on_miss = true
  []
[]

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'gold/block.msh'
  []
  coord_type = RZ
[]

[Variables]
  [alpha]
  []
[]

[AuxVariables]
  [M]
    order = CONSTANT
    family = MONOMIAL
    [InitialCondition]
      type = ConstantIC
      value = 1
    []
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
  [reaction]
    type = MaterialSource
    variable = alpha
    prop = alpha_rate
    prop_derivative = alpha_rate_derivative
    coefficient = 1
  []
[]

[NEML2]
  input = 'Si_SiC_C.i'

  [all]
    model = 'model'
    verbose = true
    device = 'cpu'

    moose_input_types = 'VARIABLE     POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL'
    moose_inputs = '     alpha        time          time          phi_p         phi_s'
    neml2_inputs = '     forces/alpha forces/t      old_forces/t  old_state/phi_p old_state/phi_s'

    moose_output_types = 'MATERIAL    MATERIAL    MATERIAL    MATERIAL'
    moose_outputs = '     phi_p       phi_s       phi_l       alpha_rate'
    neml2_outputs = '     state/phi_p state/phi_s state/phi_l state/alpha_rate'

    moose_derivative_types = 'MATERIAL                       MATERIAL                  MATERIAL                  MATERIAL'
    moose_derivatives = '     alpha_rate_derivative          phi_p_derivative          phi_s_derivative          phi_l_derivative'
    neml2_derivatives = '     state/alpha_rate forces/alpha; state/phi_p forces/alpha; state/phi_s forces/alpha; state/phi_l forces/alpha'

    initialize_outputs = '      phi_p  phi_s'
    initialize_output_values = 'phi_p0 phi_s0'
  []
[]

[Materials]
  [initial_state]
    type = GenericConstantMaterial
    prop_names = 'D phi_p0 phi_s0'
    prop_values = '${D} ${phi_p0} ${phi_s0}'
  []
[]

[Functions]
  [flux]
    type = PiecewiseLinear
    x = '0 ${t_ramp}'
    y = '0 ${flux}'
  []
[]

[BCs]
  [inlet]
    type = InfiltrationWake
    variable = alpha
    boundary = 'inlet'
    inlet_flux = 'flux'
    outlet_flux = 'flux'
    solid_fraction = phi_s
    solid_fraction_derivative = phi_s_derivative
    liquid_fraction = phi_l
    liquid_fraction_derivative = phi_l_derivative
    product_fraction = phi_p
    product_fraction_derivative = phi_p_derivative
    multiplier = M
  []
[]

[Postprocessors]
  [time]
    type = TimePostprocessor
    execute_on = 'INITIAL TIMESTEP_BEGIN'
    outputs = 'csv'
  []
  [inlet_rate]
    type = SideDiffusiveFluxIntegral
    diffusivity = D
    variable = alpha
    boundary = 'inlet'
    execute_on = 'TIMESTEP_END'
  []
  [volume_rate]
    type = ParsedPostprocessor
    expression = 'inlet_rate*${omega_Si}'
    pp_names = 'inlet_rate'
    execute_on = 'TIMESTEP_END'
  []
[]

[AuxVariables]
  [phi_p]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phi_p
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_l]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phi_l
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_s]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phi_s
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_0]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = ParsedAux
      expression = '1-phi_p-phi_s-phi_l'
      material_properties = 'phi_p phi_s phi_l'
      execute_on = 'INITIAL TIMESTEP_END'
    []
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
  dtmax = '${fparse 10*dt0}'

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt0}
    optimal_iterations = 6
    iteration_window = 2
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.1
    growth_factor = 1.2
    linear_iteration_ratio = 10000
  []

  fixed_point_max_its = 10
  fixed_point_algorithm = picard
  fixed_point_abs_tol = 1e-06
  fixed_point_rel_tol = 1e-08
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = 'results/out'
  []
  print_linear_residuals = false
[]
