# Input
# parameters
M = 0.576
lc = 1e-6 #m
phi0 = 0.5

# Material/system properties
oP = 1.25e-5 #m^3/mol
oL = 1.2e-5 #m^3/mol
rho_rat = 0.8
D_LP = 1e-19 # m^2/s 5e-7
sto_coef = 1.0
smooth = 70

# simulation parameters

D_macro = 1e-6
Dmulti_alphamax = 1000
#t_ramp = 5000 #s
P0 = 1e-5

n = 100
xmax = 1 #m

d0 = 0.01
alpha0 = 20000

#alphamin = 1

r10 = '${fparse phi0^(1/2) - M*d0^2}'
h0 = 1.0

aP0 = '${fparse 1/oP*(2*r10*d0^2+d0^4)}'

[Mesh]
    type = GeneratedMesh
    dim = 1
    nx = '${n}'
    xmax = ${xmax}
    #ny = 1
    #ymax = 0.05
[]

[Variables]
    [alpha]
    []
    [P]
    []
[]

[AuxVariables]
    [sqrtd]
        family = MONOMIAL
        order = CONSTANT
        [AuxKernel]
            type = MaterialRealAux
            property = sqrtd
            execute_on = 'INITIAL TIMESTEP_BEGIN'
        []
    []
    [h]
        family = MONOMIAL
        order = CONSTANT
        [AuxKernel]
            type = MaterialRealAux
            property = h
            execute_on = 'INITIAL TIMESTEP_BEGIN'
        []
    []
    [asource]
        family = MONOMIAL
        order = CONSTANT
        [AuxKernel]
            type = MaterialRealAux
            property = alpha_source
            execute_on = 'INITIAL TIMESTEP_BEGIN'
        []
    []
    [product_sat]
        family = MONOMIAL
        order = CONSTANT
        [AuxKernel]
            type = MaterialRealAux
            property = alphaP
            execute_on = 'INITIAL TIMESTEP_BEGIN'
        []
    []
    [diff_coeff]
        family = MONOMIAL
        order = CONSTANT
        [AuxKernel]
            type = MaterialRealAux
            property = Deff
            execute_on = 'INITIAL TIMESTEP_BEGIN'
        []
    []
[]

[Kernels]
    [diff]
        #type = FunctionDiffusion
        #variable = alpha
        #function = ${D_macro}
        type = PumaDiffusion
        variable = alpha
        diffusivity = Deff
        diffusivity_derivative = neml2_diff_jacobian
        pressure = P
    []
    [diff_time]
        type = TimeDerivative
        variable = alpha
    []
    [source_sink]
        type = MaterialSource
        variable = alpha
        prop = 'alpha_source'
        prop_derivative = 'neml2_jacobian'
        coefficient = 1
    []
    [pressure]
        type = PumaPressure
        liquid_saturation = alpha
        material_pressure = 'P'
        material_pressure_derivative = 'neml2_P_jacobian'
        variable = P
    []
[]

[NEML2]
    input = 'neml2/Si_SiC_C.i'
    cli_args = 'phi0=${phi0} M=${M} lc=${lc} oP=${oP} oL=${oL} rho_rat=${rho_rat} D_LP=${D_LP} sto_coef=${sto_coef} smooth=${smooth} D_macro=${D_macro} Dmulti_alphamax=${Dmulti_alphamax} P0=${P0}'

    [all]
        model = 'model'
        verbose = true
        device = 'cpu'

        moose_input_types = 'VARIABLE     VARIABLE         POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL    MATERIAL'
        moose_inputs = '     alpha        alpha            time          time          sqrtd           h           alphaP'
        neml2_inputs = '     forces/alpha old_forces/alpha forces/tt     old_forces/tt old_state/delta old_state/h old_state/alphaP'

        #moose_input_types = 'VARIABLE     VARIABLE         POSTPROCESSOR POSTPROCESSOR MATERIAL        MATERIAL'
        #moose_inputs = '     alpha        alpha            time          time          sqrtd           h        '
        #neml2_inputs = '     forces/alpha old_forces/alpha forces/tt     old_forces/tt old_state/delta old_state/h'

        #moose_parameter_types = 'MATERIAL MATERIAL'
        #moose_parameters = 'phi0 phi0'
        #neml2_parameters = 'inlet_gap_phi0 perfect_growth_phi0'

        moose_output_types = 'MATERIAL           MATERIAL    MATERIAL MATERIAL     MATERIAL   MATERIAL'
        moose_outputs = '     alpha_source       sqrtd       h        alphaP       Deff       P'
        neml2_outputs = '     state/alpha_source state/delta state/h  state/alphaP state/Deff state/P'

        moose_derivative_types = 'MATERIAL                    MATERIAL                 MATERIAL'
        moose_derivatives = 'neml2_jacobian                   neml2_diff_jacobian      neml2_P_jacobian'
        neml2_derivatives = 'state/alpha_source forces/alpha; state/Deff forces/alpha; state/P forces/alpha'

        initialize_outputs = '      sqrtd h    alphaP Deff'
        initialize_output_values = 'd0    h0   aP0    Deff0'
    []
[]

[Materials]
    [init_mat]
        type = GenericConstantMaterial
        prop_names = 'd0 h0 aP0 phi0 Deff0'
        prop_values = '${d0} ${h0} ${aP0} ${phi0} ${D_macro}'
    []
[]

[Postprocessors]
    [time]
        type = TimePostprocessor
        execute_on = 'INITIAL TIMESTEP_BEGIN'
    []
    #[phi0]
    #    type = ConstantPostprocessor
    #    value = ${phi0}
    #[]
[]

[VectorPostprocessors]
    #[alpha]
    #    type = NodalValueSampler
    #    variable = 'alpha'
    #    sort_by = 'id'
    #[]
    #[h_delta]
    #    type = ElementValueSampler
    #    variable = 'sqrtd h'
    #    sort_by = 'id'
    #[]
    [line]
        type = LineValueSampler
        start_point = '0 0 0'
        end_point = '${xmax} 0 0'
        num_points = ${n}
        variable = 'alpha h sqrtd asource diff_coeff P'
        sort_by = 'x'
    []
[]

[ICs]
    [alphaIC]
        type = ConstantIC
        variable = alpha
        value = ${alpha0}
    []
[]

[BCs]
    #[left1]
    #    type = FunctionNeumannBC
    #    variable = alpha
    #    boundary = left
    #    function = 'if(t<${t_ramp},0.5*t/${t_ramp},0.5)'
    #[]
    #[left2]
    #    type = DirichletBC
    #    variable = alpha
    #    boundary = left
    #    value = '${almax}'
    #[]
    #[right1]
    #    type = NeumannBC
    #    variable = alpha
    #    boundary = right
    #    value = 0.0
    #[]
    #[right2]
    #    type = DirichletBC
    #    variable = alpha
    #    boundary = right
    #    value = ${alpha0}
    #[]
[]

[Executioner]
    type = Transient
    solve_type = 'newton'
    petsc_options_iname = '-pc_type -snes_type'
    petsc_options_value = 'lu vinewtonrsls'
    automatic_scaling = true
    # line_search = none

    # reuse_preconditioner = true
    # reuse_preconditioner_max_linear_its = 25

    #nl_max_its = 12

    nl_abs_tol = 1e-8
    #nl_abs_rel = 1e-8

    end_time = 108000 #10800
    dt = 200 #s

    # [TimeStepper]
    #     type = IterationAdaptiveDT
    #     dt = 0.1
    #     growth_factor = 1.1
    #     cutback_factor = 0.5
    #     cutback_factor_at_failure = 0.1
    #     optimal_iterations = 7
    #     iteration_window = 3
    #     linear_iteration_ratio = 100000
    # []

    # [Predictor]
    #     type = SimplePredictor
    #     scale = 1
    # []
[]

[Postprocessors]
    [alpha_min]
        type = NodalExtremeValue
        variable = alpha
        value_type = min
        execute_on = 'INITIAL TIMESTEP_END'
    []
[]

[UserObjects]
    [stop]
        type = Terminator
        expression = 'alpha_min > 3e4'
        message = 'We have completely filled up the foam'
    []
[]

[Outputs]
    exodus = true
    [csv]
        type = CSV
        file_base = 'solution11/out'
    []
    [console]
        type = Console
        execute_postprocessors_on = 'NONE'
    []
    print_linear_residuals = false
[]