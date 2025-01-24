n = 100
xmax = 1

[Mesh]
    type = GeneratedMesh
    dim = 2
    nx = '${n}'
    xmax = ${xmax}
    ny = 1
    ymax = 0.05
[]

[Variables]
    [alpha]
    []
[]

[Kernels]
    [diffusion]
        type = MatDiffusion
        variable = alpha
        diffusivity = D
        args = 'alpha'
    []
    [diff_time]
        type = TimeDerivative
        variable = alpha
    []
[]

[Materials]
    [D]
        type = DerivativeParsedMaterial
        property_name = D
        expression = 'if(alpha<1e3,0.01,0.01+100*(alpha-1e3))'
        coupled_variables = 'alpha'
    []
[]

[BCs]
    [left1]
        type = NeumannBC
        variable = alpha
        boundary = left
        value = 100
    []
    #[left2]
    #    type = DirichletBC
    #    variable = alpha
    #    boundary = left
    #    value = 16000
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
    #line_search = none

    # reuse_preconditioner = true
    # reuse_preconditioner_max_linear_its = 25

    #nl_max_its = 12

    nl_abs_tol = 1e-8
    #nl_abs_rel = 1e-8

    end_time = 10 #
    dt = 0.01 #s
[]

[Postprocessors]
    [total]
        type = ElementIntegralVariablePostprocessor
        variable = alpha
        execute_on = 'INITIAL TIMESTEP_END'
    []
[]

[Outputs]
    exodus = true
    [csv]
        type = CSV
        file_base = 'solution4/out'
    []
    [console]
        type = Console
        # execute_postprocessors_on = 'NONE'
    []
    print_linear_residuals = false
[]