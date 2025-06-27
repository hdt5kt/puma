############### Input ################
# Simulation parameters
dt = 20
nx = 40

# models
Ts = 1687
Tf = 1727

# Molar Mass # g mol-1
M_Si = 28.085

# solidfication information
H_latent = 1.8e8 # erg/g
Tmax = 1800 #K
T0 = 300 #K

# fluid information
swelling_coef = 0.02

# density
rho_Si = 2.57 # density at liquid state
rho_Si_s = 2.37 # density at solid state

# specific heat
cp_Si = 0.7e7 # erg/g-K
cp_Si_s = 0.5e7 # erg/g-K

# Heating conditions
dTdt = -10 #Kmin-1 heating rate
t_ramp = '${fparse (T0-Tmax)/dTdt*60}' #s
total_time = '${fparse t_ramp}'

# thermal conductivity
kappa_eff = 4e4 #[gcm/s3/K]

# solid mechnanics
E = 100e9
nu = 0.3
g = 1e-6
Tref = 300

# boundary conditions
htc = 20000 #g / s3-K

# porous flow
brooks_corey_threshold = 1e4 #Pa
capillary_pressure_power = 3

permeability_power = 3

# liquid viscosity
mu_Si = 10

# solid permeability
kk_Si = 2e-5

# macroscopic property
D_macro = 0.001 #cm2 s-1

phi_solid0 = 0.2

xmax = 2.0

gravity = 0.0 # 980.665 # cm/s2

# Calculations
omega_Si_s = '${fparse M_Si/rho_Si_s}'
omega_Si_l = '${fparse M_Si/rho_Si}'
dOmega_f = '${fparse (omega_Si_s-omega_Si_l)/omega_Si_l}'

[GlobalParams]
    temperature = 'T'
    pressure = 'P'
    displacements = 'disp_x disp_y'
    stabilize_strain = true
    fluid_fraction = 'phif'
[]

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = '${nx}'
    ny = '${nx}'
    xmax = '${xmax}'
    ymax = '${xmax}'
[]

[Variables]
    [T]
    []
    [P]
    []
    [phif]
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
    ## Pressure ---------------------------------------------------------------
    [L2]
        type = CoupledL2Projection
        material_prop = M5
        variable = P
        material_fluid_fraction_derivative = dM5dphif
        material_pressure_derivative = dM5dP
        material_temperature_derivative = dM5dT
        material_deformation_gradient_derivative = dM5dF
    []
    ## Temperature flow ---------------------------------------------------------
    [temp_time]
        type = PumaCoupledTimeDerivative
        material_prop = M6
        variable = T
        material_temperature_derivative = dM6dT
        material_pressure_derivative = dM6dP
        material_fluid_fraction_derivative = dM6dphif
        material_deformation_gradient_derivative = dM6dF
    []
    [temp_diffusion]
        type = PumaCoupledDiffusion
        material_prop = M7
        variable = T
        material_temperature_derivative = dM7dT
        material_pressure_derivative = dM7dP
        material_fluid_fraction_derivative = dM7dphif
        material_deformation_gradient_derivative = zeroR2
    []
    [temp_darcy_nograv]
        type = PumaCoupledDarcyFlow
        coupled_variable = P
        material_prop = M8
        variable = T
        material_fluid_fraction_derivative = dM8dphif
        material_pressure_derivative = dM8dP
        material_temperature_derivative = dM8dT
        material_deformation_gradient_derivative = zeroR2
    []
    [temp_gravity]
        type = CoupledAdditiveFlux
        material_prop = M9
        value = '0.0 ${g} 0.0'
        variable = T
        material_fluid_fraction_derivative = dM9dphif
        material_pressure_derivative = dM9dP
        material_temperature_derivative = dM9dT
        material_deformation_gradient_derivative = zeroR2
    []
    [reaction_heat]
        type = CoupledMaterialSource
        material_prop = M10
        variable = T
        material_temperature_derivative = dM10dT
        material_fluid_fraction_derivative = dM10dphif
        material_pressure_derivative = dM10dP
        material_deformation_gradient_derivative = dM10dF
    []
    ## solid mechanics ---------------------------------------------------------
    [offDiagStressDiv_x]
        type = MomentumBalanceCoupledJacobian
        component = 0
        variable = disp_x
        material_temperature_derivative = dpk1dT
        material_pressure_derivative = zeroR2
        material_fluid_fraction_derivative = dpk1dphif
    []
    [offDiagStressDiv_y]
        type = MomentumBalanceCoupledJacobian
        component = 1
        variable = disp_y
        material_temperature_derivative = dpk1dT
        material_pressure_derivative = zeroR2
        material_fluid_fraction_derivative = dpk1dphif
    []
[]

[NEML2]
    input = 'neml2/neml2_material.i'
    cli_args = 'cp_rho_Si=${fparse cp_Si*rho_Si} cp_rho_Si_s=${fparse cp_Si_s*rho_Si_s}
                Ts=${Ts} Tf=${Tf} mL=${fparse rho_Si*H_latent}
                swelling_coef=${swelling_coef} dOmega_f=${dOmega_f} Tref=${Tref}
                kappa_eff=${kappa_eff} E=${E} nu=${nu} therm_expansion=${g}
                rho_f=${rho_Si} Drho_f=${fparse D_macro*rho_Si}
                kk_L=${kk_Si} permeability_power=${permeability_power}
                rhof_nu=${fparse rho_Si/mu_Si} rhof2_nu=${fparse rho_Si^2/mu_Si}
                brooks_corey_threshold=${brooks_corey_threshold}
                capillary_pressure_power=${capillary_pressure_power}
                hf_rhof_nu=${fparse H_latent*rho_Si/mu_Si}
                hf_rhof2_nu=${fparse H_latent*rho_Si^2/mu_Si}'
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'POSTPROCESSOR POSTPROCESSOR
                             VARIABLE      VARIABLE      VARIABLE    MATERIAL'
        moose_inputs = '     time          time
                             T             T             phif        deformation_gradient'
        neml2_inputs = '     forces/t      old_forces/t
                             forces/T      old_forces/T  forces/phif forces/F'

        moose_parameter_types = 'MATERIAL    '
        moose_parameters = '     phisp              '
        neml2_parameters = '     phisp_param  '

        moose_output_types = 'MATERIAL   MATERIAL   MATERIAL     MATERIAL       MATERIAL
                              MATERIAL   MATERIAL   MATERIAL     MATERIAL       MATERIAL
                              MATERIAL   MATERIAL   MATERIAL     MATERIAL       MATERIAL'
        moose_outputs = '     M6         M10        phif_l       phif_s         omcliquid
                              pk1_stress M1         M2           M3             M4
                              M5         M8         M9           phif_max       perm'
        neml2_outputs = '     state/M6   state/M10  state/phif_l state/phif_s   state/omcliquid
                              state/pk1  state/M1   state/M2     state/M3       state/M4
                              state/M5   state/M8   state/M9     state/phif_max state/perm'

        moose_derivative_types = 'MATERIAL              MATERIAL               MATERIAL
                                  MATERIAL              MATERIAL               MATERIAL
                                  MATERIAL              MATERIAL               MATERIAL
                                  MATERIAL
                                  MATERIAL              MATERIAL               MATERIAL
                                  MATERIAL              MATERIAL               MATERIAL
                                  MATERIAL              MATERIAL               MATERIAL
                                  MATERIAL              MATERIAL               MATERIAL'
        moose_derivatives = '     dM1dT                 dM2dT                  dM3dT
                                  dM4dT                 dM5dT                  dM6dT
                                  dM8dT                 dM9dT                  dM10dT
                                  dM3dphif
                                  dM4dphif              dM5dphif               dM6dphif
                                  dM8dphif              dM9dphif               dM1dF
                                  dM5dF                 dM6dF                  dM10dF
                                  dpk1dT                dpk1dphif              pk1_jacobian'
        neml2_derivatives = '     state/M1 forces/T;    state/M2 forces/T;     state/M3 forces/T;
                                  state/M4 forces/T;    state/M5 forces/T;     state/M6 forces/T;
                                  state/M8 forces/T;    state/M9 forces/T;     state/M10 forces/T;
                                  state/M3 forces/phif;
                                  state/M4 forces/phif; state/M5 forces/phif;  state/M6 forces/phif;
                                  state/M8 forces/phif; state/M9 forces/phif;  state/M1 forces/F;
                                  state/M5 forces/F;    state/M6 forces/F;     state/M10 forces/F;
                                  state/pk1 forces/T;   state/pk1 forces/phif; state/pk1 forces/F'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'M7'
        prop_values = '${kappa_eff}'
    []
    [init_mat_derivative]
        type = GenericConstantMaterial
        prop_names = ' dM7dT     dM1dP      dM2dP     dM3dP      dM4dP dM5dP dM6dP dM7dP dM8dP dM9dP dM10dP
                       dM1dphif  dM2dphif   dM7dphif  dM10dphif'
        prop_values = '0.0       0.0        0.0       0.0        0.0   0.0   0.0   0.0   0.0   0.0   0.0
                       0.0       0.0        0.0       0.0'
    []
    [void_feature]
        type = GenericConstantMaterial
        prop_names = 'phisp'
        prop_values = '${phi_solid0}'
    []
    [zeroR2]
        type = GenericConstantRankTwoTensor
        tensor_name = 'zeroR2'
        tensor_values = '0 0 0 0 0 0 0 0 0'
    []
    [convection]
        type = ADParsedMaterial
        property_name = q_boundary
        expression = 'htc*(T - if(time<t_ramp, Tmax + dTdt/60*time, Tmax + dTdt/60*t_ramp))'
        coupled_variables = T
        constant_names = 'htc t_ramp dTdt  Tmax'
        constant_expressions = '${htc} ${t_ramp} ${dTdt} ${Tmax}'
        postprocessor_names = 'time'
        boundary = 'bottom'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
[]

[AuxVariables]
    [heat_release]
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
            property = omcliquid
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
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
    [phif_max]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = phif_max
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
    [perm]
        order = CONSTANT
        family = MONOMIAL
        [AuxKernel]
            type = MaterialRealAux
            property = perm
            execute_on = 'INITIAL TIMESTEP_END'
        []
    []
[]

[ICs]
    [T_IC]
        type = ConstantIC
        variable = T
        value = ${Tmax}
    []
    [phif_IC]
        type = ConstantIC
        variable = phif
        value = 0.5
    []
[]

[Functions]
    [tramp]
        type = PiecewiseLinear
        x = '0 ${t_ramp}'
        y = '${Tmax} ${T0}'
    []
[]

[BCs]
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = 'bottom'
        variable = T
        value = -1
    []
    [roll_y]
        type = DirichletBC
        boundary = 'bottom'
        value = 0.0
        variable = disp_y
    []
    [roll_x]
        type = DirichletBC
        boundary = 'bottom'
        value = 0.0
        variable = disp_x
    []
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options_iname = '-pc_type -snes_type'
    petsc_options_value = 'lu vinewtonrsls'
    automatic_scaling = true

    nl_abs_tol = 1e-05
    nl_rel_tol = 1e-08
    nl_max_its = 12

    end_time = ${total_time}
    dtmax = '${fparse 10*dt}'

    [TimeStepper]
        type = IterationAdaptiveDT
        dt = ${dt} #s
        optimal_iterations = 7
        iteration_window = 2
        cutback_factor = 0.5
        cutback_factor_at_failure = 0.1
        growth_factor = 1.2
        linear_iteration_ratio = 10000
    []
[]

[Outputs]
    exodus = true
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
    []
    print_linear_residuals = false
[]