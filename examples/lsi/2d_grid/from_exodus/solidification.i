############### Input ################

# Simulation parameters
dt = 5 #s

t_ramp = 1800

dTdt = -0.83333 # deg per s

# Molar Mass # g mol-1
M_Si = 0.028085

# thermal conductivity
kappa_eff = 100 #[gcm/s3/K]

#boundary conditions
htc = 100 #g / s3-K

#solidification information
Ts = 1687 #K
Tf = '${fparse Ts+30}' #K

H_latent = 1800e0 #J/kg
# denisty # kg m-3
rho_Si = 2.57e3 # density at liquid state
rho_SiC = 3.21e3
rho_C = 2.26e3

# heat capacity Jkg-1K-1
cp_Si = 7.1e2
cp_SiC = 5.5e2
cp_C = 1.5e2
rho_Si_s = 2.37e3 # density at solid state
swelling_coef = 1e-2

E = 400e9
nu = 0.3
therm_expansion = 1e-6
T0 = 1730
Tref = 1730
total_time = 3600 #s

# --------------- Mesh BCs
xroll = 0.1
yroll = 0
zroll = 0
xfix = 0
yfix = 0
zfix = 0

meshfile = 'gold/2D_plane.msh'

omega_Si_s = '${fparse M_Si/rho_Si_s}'
omega_Si_l = '${fparse M_Si/rho_Si}'
dOmega_f = '${fparse (omega_Si_s-omega_Si_l)/omega_Si_l}'

[GlobalParams]
  displacements = 'disp_x disp_y'
  temperature = T
  fluid_fraction = phif
[]

[Variables]
  [T]
  []
  [phif]
  []
[]

[Kernels]
  ## Temperature flow ---------------------------------------------------------
  [temp_time]
    type = PumaCoupledTimeDerivative
    material_prop = M6
    variable = T
    material_temperature_derivative = dM6dT
    material_fluid_fraction_derivative = dM6dphif
    material_deformation_gradient_derivative = dM6dF
    stabilize_strain = true
  []
  [temp_diffusion]
    type = PumaCoupledDiffusion
    material_prop = M7
    variable = T
    material_temperature_derivative = dM7dT
    material_fluid_fraction_derivative = dM7dphif
    material_deformation_gradient_derivative = zeroR2
    stabilize_strain = true
  []
  [temp_source]
    type = PumaCoupledTimeDerivative
    material_prop = M10
    variable = T
    material_temperature_derivative = dM10dT
    material_fluid_fraction_derivative = dM10dphif
    material_deformation_gradient_derivative = dM10dF
    stabilize_strain = true
  []
  ## no fluid flow---------------------------------------------------------
  [phif_time]
    type = PumaCoupledTimeDerivative
    material_prop = 1
    variable = phif
    material_temperature_derivative = 0
    material_fluid_fraction_derivative = 0
    material_deformation_gradient_derivative = zeroR2
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
                            pk1_stress_xy pk1_stress_xz pk1_stress_yz
                            vonmises_pk1_stress max_principal_pk1_stress"
      []
    []
  []
[]

[NEML2]
  input = 'neml2/neml2_solidification.i'
  cli_args = 'rho_f=${fparse rho_Si}
              nu=${nu}
              therm_expansion=${therm_expansion} Tref=${Tref}
              Ts=${Ts} Tf=${Tf} swelling_coef=${swelling_coef}
              rhofL=${fparse rho_Si*H_latent} dOmega_f=${dOmega_f}
              rhocp_Si=${fparse rho_Si*cp_Si} rhocp_SiC=${fparse rho_SiC*cp_SiC}
              rhocp_C=${fparse rho_C*cp_C} E=${E} mL=${fparse rho_Si*H_latent}'
  [all]
    model = 'model'
    verbose = true
    device = 'cpu'

    moose_input_types = 'VARIABLE     VARIABLE      VARIABLE      POSTPROCESSOR POSTPROCESSOR MATERIAL     '
    moose_inputs = '     T            T             phif          time          time          deformation_gradient'
    neml2_inputs = '     old_forces/T forces/T      forces/phif   forces/t      old_forces/t  forces/F'

    moose_parameter_types = 'MATERIAL    MATERIAL    MATERIAL   '
    moose_parameters = '     phis        phip        phinoreact              '
    neml2_parameters = '     phis_param  phip_param  phinoreact_param '

    moose_output_types = 'MATERIAL     MATERIAL   MATERIAL   MATERIAL     MATERIAL
                          MATERIAL     MATERIAL'
    moose_outputs = '     pk1_stress   M6         M10        phif_l       M7
                          phif_s       solidification_fraction'
    neml2_outputs = '     state/pk1    state/M6   state/M10  state/phif_l state/M7
                          state/phif_s state/omcliquid'

    moose_derivative_types = 'MATERIAL               MATERIAL
                              MATERIAL               MATERIAL
                              MATERIAL               MATERIAL
                              MATERIAL'
    moose_derivatives = '     pk1_jacobian           dpk1dT
                              dM10dT                 dM10dF
                              dpk1dphif              dM6dF
                              dM7dT'
    neml2_derivatives = '     state/pk1 forces/F;    state/pk1 forces/T;
                              state/M10 forces/T;    state/M10 forces/F;
                              state/pk1 forces/phif; state/M6  forces/F;
                              state/M7  forces/T'
  []
[]

[Materials]

  [constant_derivative]
    type = GenericConstantMaterial
    prop_names = ' dM6dT       dM7dT dM6dphif dM7dphif dM10dphif'
    prop_values = '0.0         0.0   0.0      0.0      0.0'
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
    boundary = 'interface'
  []
[]

[Postprocessors]
  [time]
    type = TimePostprocessor
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[BCs]
  [boundary]
    type = ADMatNeumannBC
    boundary_material = q_boundary
    boundary = 'interface'
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
  file_base = 'solidification'
  [console]
    type = Console
    execute_postprocessors_on = 'NONE'
  []
  [csv]
    type = CSV
    file_base = 'solidification'
  []
  print_linear_residuals = false
[]
