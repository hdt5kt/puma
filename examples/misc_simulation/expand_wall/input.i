#### Input ####

dt = 5 #s

dTdt = -0.83333 # deg per s

Tstart = 1687 #K
Tend = 300 #K

# Molar Mass # kg mol-1
M_Si = 0.028 # 28.085

# denisty # kg m-3
rho_Si = 2.57e3 # density at liquid state
rho_Si_s = 2.37e3 # density at solid state
rho_SiC = 3.21e3

# heat capacity Jkg-1K-1
cp_Si = 7.1e2
cp_SiC = 5.5e2

filename = "cane_modified_0p1"
meshfile = 'gold/${filename}.msh'

# yound modulus (N) and poisson ratio
E_Si = 185e9
E_SiC = 400e9
nu = 0.3

# thermal conductivity
kappa_eff = 200 #[kgm/s3/K]

# thermal expansion coefficients
g_Si = 3.0e-6
Tref = '${Tend}'
g_SiC = 4.0e-6

#boundary conditions
htc = 1000 #kg / s3-K

#### Calculations ####
omega_Si_s = '${fparse M_Si/rho_Si_s}'
omega_Si_l = '${fparse M_Si/rho_Si}'
dOmega_f = '${fparse (omega_Si_s-omega_Si_l)/omega_Si_l}'

t_ramp = '${fparse (Tstart-Tend)/(-dTdt)}' #s
total_time = '${fparse t_ramp + 3*3600}'

[GlobalParams]
    displacements = 'disp_x disp_y'
    temperature = T
    stabilize_strain = true
[]

[Mesh]
    [mesh0]
        type = FileMeshGenerator
        file = '${meshfile}'
    []
    [scale]
        type = TransformGenerator
        vector_value = '0.01 0.01 0.01'
        transform = SCALE
        input = mesh0
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
        material_prop = M1
        variable = T
        material_temperature_derivative = dM1dT
        material_deformation_gradient_derivative = dM1dF
    []
    [temp_diffusion]
        type = PumaCoupledDiffusion
        material_prop = M2
        variable = T
        material_temperature_derivative = dM2dT
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
                                    pk1_stress_xy pk1_stress_xz pk1_stress_yz vonmises_pk1_stress
                                    max_principal_pk1_stress"
            []
        []
    []
[]

[NEML2]
    input = 'neml2/neml2_material.i'
    cli_args = 'dOmega_f=${dOmega_f} Tref=${Tref} nu=${nu}
              rhocp_Si=${fparse rho_Si*cp_Si} rhocp_SiC=${fparse rho_SiC*cp_SiC} '
    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = ' VARIABLE    MATERIAL'
        moose_inputs = '      T           deformation_gradient'
        neml2_inputs = '      forces/T    forces/F'

        moose_parameter_types = 'MATERIAL       MATERIAL    MATERIAL   MATERIAL'
        moose_parameters = '     g_thermal      E           phif       phip    '
        neml2_parameters = '     Fthermal_alpha S_pk2_E     phif_param phip_param'

        moose_output_types = 'MATERIAL     MATERIAL   MATERIAL'
        moose_outputs = '     pk1_stress   M1         Fe'
        neml2_outputs = '     state/pk1    state/M1   state/Fe'

        moose_derivative_types = 'MATERIAL               MATERIAL
                                  MATERIAL               '
        moose_derivatives = '     pk1_jacobian           dpk1dT
                                  dM1dF                 '
        neml2_derivatives = '     state/pk1 forces/F;    state/pk1 forces/T;
                                  state/M1 forces/F'
    []
[]

[Materials]
    [constant_derivative]
        type = GenericConstantMaterial
        prop_names = ' dM1dT dM2dT'
        prop_values = '0.0   0.0'
    []
    [constant]
        type = GenericConstantMaterial
        prop_names = ' M2'
        prop_values = '${fparse kappa_eff}'
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
        constant_expressions = '${htc} ${t_ramp} ${dTdt} ${Tstart}'
        postprocessor_names = 'time'
        boundary = 'top right'
    []
    [Si]
        type = GenericConstantMaterial
        prop_names = ' g_thermal E     phif phip'
        #prop_values = '${g_Si} ${E_Si} 1.0  0.0'
        prop_values = '${g_Si} ${E_Si} 0.0  1.0'
        block = 'Si'
    []
    [SiC]
        type = GenericConstantMaterial
        prop_names = ' g_thermal E       phif phip'
        prop_values = '${g_SiC} ${E_SiC} 0.0  1.0'
        block = 'SiC'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
    [max_pk1_v]
        type = ElementExtremeMaterialProperty
        mat_prop = vonmises_pk1_stress
        value_type = max
        execute_on = 'INITIAL TIMESTEP_END'
        block = 'SiC'
    []
    [max_pk1_principal]
        type = ElementExtremeMaterialProperty
        mat_prop = max_principal_pk1_stress
        value_type = max
        execute_on = 'INITIAL TIMESTEP_END'
        block = 'SiC'
    []
[]

# [Constraints]
#     [y_top]
#         type = EqualValueBoundaryConstraint
#         variable = disp_y
#         secondary = 'top'
#         penalty = 10e10
#     []
#     [x_right]
#         type = EqualValueBoundaryConstraint
#         variable = disp_x
#         secondary = 'right'
#         penalty = 10e10
#     []
# []

[BCs]
    [boundary]
        type = ADMatNeumannBC
        boundary_material = q_boundary
        boundary = 'top right'
        variable = T
        value = -1
    []
    [roller_bottom]
        type = DirichletBC
        boundary = bottom
        value = 0.0
        variable = disp_y
    []
    [roller_left]
        type = DirichletBC
        boundary = left
        value = 0.0
        variable = disp_x
    []
    [fix_top]
        type = DirichletBC
        boundary = top
        value = 0.0
        variable = disp_y
    []
    [fix_right]
        type = DirichletBC
        boundary = right
        value = 0.0
        variable = disp_x
    []
[]

[ICs]
    [temp]
        type = ConstantIC
        value = ${Tstart}
        variable = T
    []
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options_iname = '-pc_type -snes_type'
    petsc_options_value = 'lu vinewtonrsls'
    automatic_scaling = true

    line_search = none

    nl_abs_tol = 1e-06
    nl_rel_tol = 1e-08
    nl_max_its = 12

    end_time = ${total_time}
    dtmax = '${fparse 1000*dt}'

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
[]

[Outputs]
    exodus = true
    file_base = 'out/${filename}'
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    [csv]
        type = CSV
        file_base = 'out/${filename}'
    []
    print_linear_residuals = false
[]