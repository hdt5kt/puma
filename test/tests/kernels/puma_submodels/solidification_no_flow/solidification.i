############### Input ################

# Simulation parameters
dt = 5 #s

t_ramp = 1800

dTdt = -0.83333 # deg per s

# Molar Mass # g mol-1
M_Si = 28.085

# thermal conductivity
kappa_eff = 4e4 #[gcm/s3/K]

#boundary conditions
htc = 2e6 #g / s3-K

#solidification information
Ts = 1687 #K
Tf = '${fparse Ts+20}' #K
H_latent = 5.0555e5 #egs/mol
rho_Si = 2.57 # density at liquid state
rho_Si_s = 2.37 # density at solid state
swelling_coef = 0.0
omega_Si_s = '${fparse M_Si/rho_Si_s}'
omega_Si_l = '${fparse M_Si/rho_Si}'
dOmega_f = '${fparse omega_Si_s-omega_Si_l}'

# composite information
rhocp_eff = 1.84e7

# initial condition
phisp_feature = 0.8
void_feature = 0.001
phisp_background = 0.2
void_background = 0.001

E = 1000
nu = 0.3
therm_expansion = 1e-6
T0 = 1800
total_time = 3600 #s

E_feature = '${fparse E}'
E_background = '${fparse E}'

advs_coefficient = 10.0

# --------------- Mesh BCs
xroll = 10
yroll = 0
zroll = 0
xfix = 0
yfix = 0
zfix = 0
xdisplace_low = 8
xdisplace_high = 10
ydisplace = 10
zdisplace = 0

[GlobalParams]
  displacements = 'disp_x disp_y'
  temperature = T
[]

[Mesh]
  [mesh0]
    type = FileMeshGenerator
    file = 'gold/core.msh'
  []
  [rollingnode]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse xroll-0.00000001} ${fparse yroll-0.00000001} ${fparse zroll-0.00000001}'
    input = mesh0
    new_boundary = 'roll'
    top_right = '${fparse xroll+0.00000001} ${fparse yroll+0.00000001} ${fparse zroll+0.00000001}'
  []
  [fixnode]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse xfix-0.00000001} ${fparse yfix-0.00000001} ${fparse zfix-0.00000001}'
    input = rollingnode
    new_boundary = 'fix'
    top_right = '${fparse xfix+0.00000001} ${fparse yfix+0.00000001} ${fparse zfix+0.00000001}'
  []
  [displacenode]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse xdisplace_low-0.00000001} ${fparse ydisplace-0.00000001} ${fparse zdisplace-0.00000001}'
    input = fixnode
    new_boundary = 'displace'
    top_right = '${fparse xdisplace_high+0.00000001} ${fparse ydisplace+0.00000001} ${fparse zdisplace+0.00000001}'
  []
[]

[Variables]
  [T]
  []
[]

[Kernels]
  ## Temperature flow ---------------------------------------------------------
  [temp_time]
    type = PumaCoupledTimeDerivative
    material_prop = M6
    variable = T
    material_temperature_derivative = dM6dT
    material_deformation_gradient_derivative = zeroR2
    stabilize_strain = true
  []
  [temp_diffusion]
    type = PumaCoupledDiffusion
    material_prop = M7
    variable = T
    material_temperature_derivative = dM7dT
    material_deformation_gradient_derivative = zeroR2
    stabilize_strain = true
  []
  [temp_source]
    type = CoupledMaterialSource
    coefficient = -1
    material_prop = M10
    variable = T
    material_temperature_derivative = dM10dT
    material_deformation_gradient_derivative = dM10dF
    stabilize_strain = true
  []
  ## solid mechanics ---------------------------------------------------------
  [offDiagStressDiv_x]
    type = MomentumBalanceCoupledJacobian
    component = 0
    variable = disp_x
    material_fluid_fraction_derivative = dpk1dphif
    material_pressure_derivative = zeroR2
    material_temperature_derivative = dpk1dT
  []
  [offDiagStressDiv_y]
    type = MomentumBalanceCoupledJacobian
    component = 1
    variable = disp_y
    material_fluid_fraction_derivative = dpk1dphif
    material_pressure_derivative = zeroR2
    material_temperature_derivative = dpk1dT
  []
[]

[AuxVariables]
  [phif_l]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phif_l
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phif_s]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phif_s
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [heat_source]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = M10
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [solidification_fraction]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = solidification_fraction
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [sample]
        new_system = true
        add_variables = true
        strain = FINITE
        formulation = TOTAL
        volumetric_locking_correction = true
        generate_output = "pk1_stress_xx pk1_stress_yy pk1_stress_zz 
                            pk1_stress_xy pk1_stress_xz pk1_stress_yz vonmises_pk1_stress"
      []
    []
  []
[]

[NEML2]
  input = 'neml2/neml2_material.i'
  cli_args = 'rho_f=${fparse rho_Si}
              nu=${nu} advs_coefficient=${advs_coefficient}
              therm_expansion=${therm_expansion} Tref=${T0}
              Ts=${Ts} Tf=${Tf} swelling_coef=${swelling_coef}
              mrhofL=${fparse -rho_Si*H_latent} dOmega_f=${dOmega_f}'
  [all]
    model = 'model'
    verbose = true
    device = 'cpu'

    moose_input_types = 'POSTPROCESSOR POSTPROCESSOR
                         VARIABLE      VARIABLE      MATERIAL'
    moose_inputs = '     time          time
                         T             T             deformation_gradient'
    neml2_inputs = '     forces/t      old_forces/t
                         forces/T      old_forces/T  forces/F'

    moose_parameter_types = ' MATERIAL   MATERIAL'
    moose_parameters = '      phif       E       '
    neml2_parameters = '      phif_param S_pk2_E '

    moose_output_types = 'MATERIAL   MATERIAL   MATERIAL     MATERIAL      MATERIAL'
    moose_outputs = '     pk1_stress M10        phif_l       phif_s       solidification_fraction'
    neml2_outputs = '     state/pk1  state/M10  state/phif_l state/phif_s state/omcliquid'

    moose_derivative_types = 'MATERIAL               MATERIAL
                              MATERIAL               MATERIAL'
    moose_derivatives = '     pk1_jacobian           dpk1dT
                              dM10dT                 dM10dF'
    neml2_derivatives = '     state/pk1 forces/F;    state/pk1 forces/T;
                              state/M10 forces/T;    state/M10 forces/F'
  []
[]

[Materials]
  [constant]
    type = GenericConstantMaterial
    prop_names = ' M6                  M7'
    prop_values = '${fparse rhocp_eff} ${fparse kappa_eff}'
  []
  [constant_derivative]
    type = GenericConstantMaterial
    prop_names = ' dM6dT       dM7dT'
    prop_values = '0.0         0.0'
  []
  [void_feature]
    type = GenericConstantMaterial
    prop_names = 'phisp E'
    prop_values = '${phisp_feature} ${E_feature}'
    block = circle
  []
  [void_background]
    type = GenericConstantMaterial
    prop_names = 'phisp E'
    prop_values = '${phisp_background} ${E_background}'
    block = non_circle
  []
  [phif_feature]
    type = GenericConstantMaterial
    prop_names = 'phif'
    prop_values = '${fparse 1-phisp_feature-void_feature}'
    block = circle
  []
  [phif_background]
    type = GenericConstantMaterial
    prop_names = 'phif'
    prop_values = '${fparse 1-phisp_background-void_background}'
    block = non_circle
  []
  [zeroR2]
    type = GenericConstantRankTwoTensor
    tensor_name = 'zeroR2'
    tensor_values = '0 0 0 0 0 0 0 0 0'
  []
  [convection]
    type = ADParsedMaterial
    property_name = q_boundary
    expression = 'htc*(T - if(time<t_ramp, T0 + dTdt*time, T0 + dTdt*t_ramp))'
    coupled_variables = T
    constant_names = 'htc t_ramp dTdt  T0'
    constant_expressions = '${htc} ${t_ramp} ${dTdt} ${T0}'
    postprocessor_names = 'time'
    boundary = 'core_bottom core_top core_sides'
  []
[]

[Postprocessors]
  [time]
    type = TimePostprocessor
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[ICs]
  [temp]
    type = ConstantIC
    value = ${T0}
    variable = T
  []
[]

[BCs]
  [boundary]
    type = ADMatNeumannBC
    boundary_material = q_boundary
    boundary = 'core_bottom core_top core_sides'
    variable = T
    value = -1
  []
  [roller]
    type = DirichletBC
    boundary = roll
    value = 0.0
    variable = disp_y
  []
  [fix_x]
    type = DirichletBC
    boundary = fix
    value = 0.0
    variable = disp_x
  []
  [fix_y]
    type = DirichletBC
    boundary = fix
    value = 0.0
    variable = disp_y
  []
[]

[Executioner]
  type = Transient
  solve_type = 'newton'
  petsc_options_iname = '-pc_type' #-snes_type'
  petsc_options_value = 'lu' # vinewtonrsls'
  automatic_scaling = true

  line_search = none

  nl_abs_tol = 1e-06
  nl_rel_tol = 1e-08
  nl_max_its = 12

  end_time = ${total_time}
  dtmax = '${fparse 50*dt}'

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt} #s
    optimal_iterations = 6
    iteration_window = 2
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.1
    growth_factor = 1.2
    linear_iteration_ratio = 10000
  []

  #fixed_point_max_its = 10
  #fixed_point_algorithm = picard
  #fixed_point_abs_tol = 1e-06
  #fixed_point_rel_tol = 1e-08
[]

[Outputs]
  exodus = true
  # file_base = '${base_folder}/core'
  [console]
    type = Console
    execute_postprocessors_on = 'NONE'
  []
  [csv]
    type = CSV
    # file_base = '${base_folder}/out'
  []
  print_linear_residuals = false
[]
