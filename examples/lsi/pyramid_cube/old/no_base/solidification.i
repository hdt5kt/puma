omega_Si_s = '${fparse M_Si/rho_Si_s}'
omega_Si_l = '${fparse M_Si/rho_Si}'
dOmega_f = '${fparse (omega_Si_s-omega_Si_l)/omega_Si_l}'

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  temperature = T
  stabilize_strain = true
[]

[Variables]
  [T]
  []
[]

[Kernels]
  ## Temperature flow ---------------------------------------------------------
  [temp_time]
    type = PumaCoupledTimeDerivative
    material_prop = M6pM10
    variable = T
    material_temperature_derivative = dM6pM10dT
    material_deformation_gradient_derivative = dM6pM10dF
  []
  [temp_diffusion]
    type = PumaCoupledDiffusion
    material_prop = M7
    variable = T
    material_temperature_derivative = dM7dT
    material_deformation_gradient_derivative = zeroR2
  []
  ## solid mechanics ---------------------------------------------------------
  [offDiagStressDiv_x]
    type = MomentumBalanceCoupledJacobian
    component = 0
    variable = disp_x
    material_temperature_derivative = dpk1dT
  []
  [offDiagStressDiv_y]
    type = MomentumBalanceCoupledJacobian
    component = 1
    variable = disp_y
    material_temperature_derivative = dpk1dT
  []
  [offDiagStressDiv_z]
    type = MomentumBalanceCoupledJacobian
    component = 2
    variable = disp_z
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
  [kappa_eff]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = M7
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
                            max_principal_pk1_stress vonmises_pk1_stress"
      []
    []
  []
[]

[NEML2]
  input = 'neml2/neml2_solidification.i'
  cli_args = 'rho_f=${fparse rho_Si}
              nu=${nu} o_cp_Si=${fparse 1.0/cp_Si} H_latent=${H_latent} kappa_eff=${kappa_eff}
              therm_expansion=${therm_expansion} Tref=${Tref}
              Ts=${Ts} Tf=${Tf} swelling_coef=${swelling_coef}
              rhofL=${fparse rho_Si*H_latent} dOmega_f=${dOmega_f}
              rhocp_Si=${fparse rho_Si*cp_Si} rhocp_SiC=${fparse rho_SiC*cp_SiC}
              rhocp_C=${fparse rho_C*cp_C} E=${E} mL=${fparse rho_Si*H_latent}'
  [all]
    model = 'model'
    verbose = true
    device = 'cpu'

    moose_input_types = 'VARIABLE     VARIABLE      POSTPROCESSOR POSTPROCESSOR MATERIAL     '
    moose_inputs = '     T            T             time          time          deformation_gradient'
    neml2_inputs = '     old_forces/T forces/T      forces/t      old_forces/t  forces/F'

    moose_parameter_types = 'MATERIAL    MATERIAL    MATERIAL    MATERIAL   '
    moose_parameters = '     phif        phis        phip        phinoreact              '
    neml2_parameters = '     phif_param  phis_param  phip_param  phinoreact_param '

    moose_output_types = 'MATERIAL     MATERIAL     MATERIAL   MATERIAL     MATERIAL
                          MATERIAL     MATERIAL     MATERIAL'
    moose_outputs = '     pk1_stress   M6           M10        phif_l       M7
                          phif_s       M6pM10       solidification_fraction '
    neml2_outputs = '     state/pk1    state/M6     state/M10  state/phif_l state/M7
                          state/phif_s state/M6pM10 state/omcliquid'

    moose_derivative_types = 'MATERIAL               MATERIAL
                              MATERIAL               MATERIAL
                              MATERIAL               MATERIAL
                              MATERIAL               MATERIAL'
    moose_derivatives = '     pk1_jacobian           dpk1dT
                              dM10dT                 dM10dF
                              dM6dF                  dM6pM10dT
                              dM7dT                  dM6pM10dF'
    neml2_derivatives = '     state/pk1 forces/F;    state/pk1 forces/T;
                              state/M10 forces/T;    state/M10 forces/F;
                              state/M6  forces/F;    state/M6pM10  forces/T;
                              state/M7  forces/T;    state/M6pM10  forces/F'
  []
[]

[Materials]
  [constant_derivative]
    type = GenericConstantMaterial
    prop_names = ' dM6dT'
    prop_values = '0.0'
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
    boundary = 'back front bottom top left right'
  []
[]

[Postprocessors]
  [time]
    type = TimePostprocessor
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON

  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type' # -pc_factor_shift_type' #-snes_type'
  petsc_options_value = 'lu' # NONZERO' # vinewtonrsls'

  reuse_preconditioner = true
  reuse_preconditioner_max_linear_its = 25
  automatic_scaling = true

  residual_and_jacobian_together = 'true'

  line_search = none

  nl_abs_tol = 1e-05
  nl_rel_tol = 1e-07
  nl_max_its = 12

  l_max_its = 100
  l_tol = 1e-06

  end_time = ${total_time}
  dtmax = '${fparse 1000*dt}'

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt} #s
    optimal_iterations = 7
    iteration_window = 2
    cutback_factor = 0.2
    cutback_factor_at_failure = 0.1
    growth_factor = 1.2
    linear_iteration_ratio = 10000
  []

  [Predictor]
    type = SimplePredictor
    scale = 1.0
    skip_after_failed_timestep = true
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
