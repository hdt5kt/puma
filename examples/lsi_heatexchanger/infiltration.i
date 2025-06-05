############### Input ################

# Simulation parameters
dt = 5 #s
total_time = 3600 #s

flux_in = 0.001 # volume fraction
flux_out = 0.001
t_ramp = 500
t_heat = 200

dTdt = 1 # deg per s

brooks_corey_threshold = 1e5 #Pa
capillary_pressure_power = 3
phi_L_residual = 0.0

permeability_power = 3

# liquid viscosity
mu_Si = 1

# solid permeability
perm_ref = 2e-10

# heat enthalpy [g-cm2/s2]
hf = 1e7

# thermal conductivity
kappa_eff = 2e3 #[gcm/s3/K]

swelling_coef = 1e-2

# macroscopic property
D_macro = 0.0 #cm2 s-1

#boundary conditions
htc = 2e1 #g / s3-K

E = 1000
nu = 0.3
therm_expansion = 1e-6
T0 = 300

advs_coefficient = 10.0
meshfile = 'gold/design03.exo'
gravity = 0.0 # 980.665

# material property
D_LP = 2.65e-6 # cm2 s-1
l_c = 1.0 # cm

# Molar Mass # g mol-1
M_Si = 0.028 # 28.085
M_SiC = 0.04 #40.11
M_C = 0.012 #12.011

# denisty # g cm-3
rho_Si = 2.57e3 # density at liquid state
rho_SiC = 3.21e3
rho_C = 2.26e3

# heat capacity Jkg-1K-1
cp_Si = 7.1e2
cp_SiC = 5.5e2
cp_C = 1.5e2

# chemical reaction constant
k_C = 1.0
k_SiC = 1.0

num_file_data = 400

##
##
##
## Calculations
D_bar = '${fparse D_LP/(l_c^2)}'

omega_C = '${fparse M_C/rho_C}'
omega_Si = '${fparse M_Si/rho_Si}'
omega_SiC = '${fparse M_SiC/rho_SiC}'

oCm1 = '${fparse 1/omega_C}'
oSiCm1 = '${fparse 1/omega_SiC}'

chem_ratio = '${fparse k_SiC/k_C}'

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  pressure = P
  fluid_fraction = phif
  temperature = T
  stabilize_strain = false
[]

[Variables]
  [P]
  []
  [phif]
  []
  [T]
  []
[]

[Kernels]
  ## Fluid flow ---------------------------------------------------------
  [time]
    type = PumaCoupledTimeDerivative
    material_prop = M1
    variable = phif
    material_fluid_fraction_derivative = dM1dphif
    material_pressure_derivative = dM1dP
    material_temperature_derivative = dM1dT
    material_deformation_gradient_derivative = dM1dF
  []
  [diffusion]
    type = PumaCoupledDiffusion
    material_prop = M2
    variable = phif
    material_fluid_fraction_derivative = dM2dphif
    material_pressure_derivative = dM2dP
    material_temperature_derivative = dM2dT
    material_deformation_gradient_derivative = zeroR2
  []
  [darcy_nograv]
    type = PumaCoupledDarcyFlow
    coupled_variable = P
    material_prop = M3
    variable = phif
    material_fluid_fraction_derivative = dM3dphif
    material_pressure_derivative = dM3dP
    material_temperature_derivative = dM3dT
    material_deformation_gradient_derivative = zeroR2
  []
  [gravity]
    type = CoupledAdditiveFlux
    material_prop = M4
    value = '0.0 ${gravity} 0.0'
    variable = phif
    material_fluid_fraction_derivative = dM4dphif
    material_pressure_derivative = dM4dP
    material_temperature_derivative = dM4dT
    material_deformation_gradient_derivative = zeroR2
  []
  [L2]
    type = CoupledL2Projection
    material_prop = M5
    variable = P
    material_fluid_fraction_derivative = dM5dphif
    material_pressure_derivative = dM5dP
    material_temperature_derivative = dM5dT
    material_deformation_gradient_derivative = dM5dF
  []
  [source]
    type = CoupledMaterialSource
    material_prop = Ms
    coefficient = -1
    variable = phif
    material_fluid_fraction_derivative = dMsdphif
    material_pressure_derivative = dMsdP
    material_temperature_derivative = dMsdT
    material_deformation_gradient_derivative = zeroR2
  []
  ## Temperature flow ---------------------------------------------------------
  [temp_time]
    type = PumaCoupledTimeDerivative
    material_prop = M6
    variable = T
    material_fluid_fraction_derivative = dM6dphif
    material_pressure_derivative = dM6dP
    material_temperature_derivative = dM6dT
    material_deformation_gradient_derivative = zeroR2
  []
  [temp_diffusion]
    type = PumaCoupledDiffusion
    material_prop = M7
    variable = T
    material_fluid_fraction_derivative = dM7dphif
    material_pressure_derivative = dM7dP
    material_temperature_derivative = dM7dT
    material_deformation_gradient_derivative = zeroR2
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
  [offDiagStressDiv_z]
    type = MomentumBalanceCoupledJacobian
    component = 2
    variable = disp_z
    material_fluid_fraction_derivative = dpk1dphif
    material_pressure_derivative = zeroR2
    material_temperature_derivative = dpk1dT
  []
[]

[AuxVariables]
  [phi_C]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phis
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_SiC]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = phip
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_react]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = Ms
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [phi_nonliquid]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = non_liquid
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [porosity]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = poro
      execute_on = 'INITIAL TIMESTEP_END'
    []
  []
  [permeability]
    order = CONSTANT
    family = MONOMIAL
    [AuxKernel]
      type = MaterialRealAux
      property = perm
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
  input = 'neml2/neml2_reactive_flow.i'
  cli_args = 'kk_L=${perm_ref} permeability_power=${permeability_power} rhof_nu=${fparse rho_Si/mu_Si}
              rhof2_nu=${fparse rho_Si^2/mu_Si} phif_residual=${phi_L_residual} rho_f=${fparse rho_Si}
              brooks_corey_threshold=${brooks_corey_threshold} capillary_pressure_power=${capillary_pressure_power}
              nu=${nu} advs_coefficient=${advs_coefficient} hf_rhof_nu=${fparse hf*rho_Si/mu_Si}
              hf_rhof2_nu=${fparse hf*rho_Si^2/mu_Si} therm_expansion=${therm_expansion} Tref=${T0}
              omega_Si=${omega_Si} D=${D_bar} oSiCm1=${oSiCm1} oCm1=${oCm1}
              chem_ratio=${chem_ratio} mchem_P=${fparse -k_SiC} rhof=${rho_Si}
              rhocp_Si=${fparse rho_Si*cp_Si} rhocp_SiC=${fparse rho_SiC*cp_SiC} rhocp_C=${fparse rho_C*cp_C}
              E=${E} swelling_coef=${swelling_coef}'
  [all]
    model = 'model'
    verbose = true
    device = 'cuda'

    moose_input_types = 'POSTPROCESSOR POSTPROCESSOR  VARIABLE    VARIABLE    MATERIAL
                         MATERIAL      MATERIAL       MATERIAL    MATERIAL'
    moose_inputs = '     time          time           phif        T           deformation_gradient
                         phip          phip           phis        phis'
    neml2_inputs = '     forces/t      old_forces/t   forces/phif forces/T    forces/F
                         state/phip    old_state/phip state/phis  old_state/phis'

    moose_parameter_types = 'MATERIAL            '
    moose_parameters = '     phi0SiC_noreact       '
    neml2_parameters = '     phinoreact_param      '

    moose_output_types = 'MATERIAL       MATERIAL         MATERIAL   MATERIAL    MATERIAL    MATERIAL
                          MATERIAL       MATERIAL         MATERIAL   MATERIAL
                          MATERIAL       MATERIAL'
    moose_outputs = '     pk1_stress     M1               M6         M3          M4          M5
                          poro           phis             perm       phip
                          Ms             non_liquid     '
    neml2_outputs = '     state/pk1      state/M1         state/M6   state/M3    state/M4    state/M5
                          state/poro     state/phis       state/perm state/phip
                          state/Ms       state/phif_max '

    moose_derivative_types = 'MATERIAL                MATERIAL              MATERIAL
                              MATERIAL                MATERIAL              MATERIAL
                              MATERIAL                MATERIAL
                              MATERIAL                MATERIAL
                              MATERIAL                MATERIAL            '
    moose_derivatives = '     dM5dphif                dM1dF                 pk1_jacobian
                              dpk1dphif               dM5dF                 dpk1dT
                              dM4dphif                dM6dphif
                              dM3dphif                dMsdphif
                              dphipdphif              dphisdphif'
    neml2_derivatives = '     state/M5  forces/phif;  state/M1 forces/F;    state/pk1 forces/F;
                              state/pk1 forces/phif;  state/M5 forces/F;    state/pk1 forces/T;
                              state/M4  forces/phif;  state/M6  forces/phif;
                              state/M3  forces/phif;  state/Ms forces/phif;
                              state/phip forces/phif; state/phis forces/phif'

    initialize_outputs = '      phip     phis'
    initialize_output_values = 'phi0_SiC phi0_C'
  []
[]

[Materials]
  [constant]
    type = GenericConstantMaterial
    prop_names = 'M2                        M7'
    prop_values = '${fparse rho_Si*D_macro} ${fparse kappa_eff}'
  []
  [constant_derivative]
    type = GenericConstantMaterial
    prop_names = ' dM1dP    dM1dphif dM1dT    dM2dphif dM2dP dM2dT
                    dM3dP    dM3dT    dM4dP    dM4dT dM5dP dM5dT
                   dM6dP    dM6dT    dM7dphif dM7dP    dM7dT
                   dMsdT    dMsdP'
    prop_values = '0.0      0.0      0.0       0.0      0.0   0.0
                       0.0      0.0       0.0      0.0   0.0   0.0
                   0.0      0.0      0.0       0.0      0.0
                   0.0      0.0'
  []
  [constant_material]
    type = GenericConstantMaterial
    prop_names = 'phi0_SiC'
    prop_values = '0.0001'
    constant_on = NONE
  []
  [zeroR2]
    type = GenericConstantRankTwoTensor
    tensor_name = 'zeroR2'
    tensor_values = '0 0 0 0 0 0 0 0 0'
  []
  [convection]
    type = ADParsedMaterial
    property_name = q_boundary
    expression = 'htc*(T - if(time<t_heat, T0 + dTdt*time, T0 + dTdt*t_heat))'
    coupled_variables = T
    constant_names = 'htc t_ramp dTdt t_heat T0'
    constant_expressions = '${htc} ${t_ramp} ${dTdt} ${t_heat} ${T0}'
    postprocessor_names = 'time'
    boundary = 'bottom front top left right back'
  []
[]

[Functions]
  [flux_in]
    type = PiecewiseLinear
    x = '0 ${t_heat} ${t_ramp}'
    y = '0 0 ${flux_in}'
  []
  [flux_out]
    type = PiecewiseLinear
    x = '0 ${t_ramp}'
    y = '0 ${flux_out}'
  []
[]

[Postprocessors]
  [time]
    type = TimePostprocessor
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[BCs]
  [bottom_inlet]
    type = InfiltrationWake
    boundary = bottom
    inlet_flux = flux_in
    outlet_flux = flux_out
    product_fraction = phip
    product_fraction_derivative = dphipdphif
    solid_fraction = phis
    solid_fraction_derivative = dphisdphif
    variable = phif
  []
  [outlet]
    type = InfiltrationWake
    boundary = 'front top left right back'
    inlet_flux = 0
    outlet_flux = flux_out
    product_fraction = phip
    product_fraction_derivative = dphipdphif
    solid_fraction = phis
    solid_fraction_derivative = dphisdphif
    variable = phif
  []
  [boundary]
    type = ADMatNeumannBC
    boundary_material = q_boundary
    boundary = 'bottom front top left right back'
    variable = T
    value = -1
  []
  [roller_bot]
    type = DirichletBC
    boundary = 'B2 B4'
    value = 0.0
    variable = disp_z
  []
  [fix_x]
    type = DirichletBC
    boundary = 'B1 B3'
    value = 0.0
    variable = disp_x
  []
  [fix_y]
    type = DirichletBC
    boundary = 'B1 B3'
    value = 0.0
    variable = disp_y
  []
  [fix_z]
    type = DirichletBC
    boundary = 'B1 B3'
    value = 0.0
    variable = disp_z
  []
[]

[Executioner]
  type = Transient
  solve_type = 'newton'
  petsc_options = '-ksp_converged_reason'
  petsc_options_iname = '-pc_type -pc_factor_shift_type' #-snes_type'
  petsc_options_value = 'lu NONZERO' # vinewtonrsls'
  reuse_preconditioner = true
  automatic_scaling = true
  residual_and_jacobian_together = 'true'

  line_search = none

  nl_abs_tol = 1e-06
  nl_rel_tol = 1e-08
  nl_max_its = 12

  end_time = ${total_time}
  dtmax = '${fparse 10*dt}'

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

  [Quadrature]
    order = CONSTANT
  []

  #fixed_point_max_its = 10
  #fixed_point_algorithm = picard
  #fixed_point_abs_tol = 1e-06
  #fixed_point_rel_tol = 1e-08
[]

[Outputs]
  exodus = true
  file_base = 'infiltration'
  [console]
    type = Console
    execute_postprocessors_on = 'NONE'
  []
  [csv]
    type = CSV
    file_base = 'infiltration'
  []
  print_linear_residuals = false
[]
